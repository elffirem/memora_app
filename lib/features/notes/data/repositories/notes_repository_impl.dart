import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../models/note_model.dart';
import '../../../../core/services/notes_api_service.dart';
import '../datasources/notes_local_datasource.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesApiService _apiService;
  final NotesLocalDataSource _localDataSource;
  
  // Flag to prevent multiple syncs in the same session
  bool _hasSyncedInThisSession = false;

  NotesRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      // Try to fetch from API first
      final notesJson = await _apiService.getNotes();
      final apiNotes = notesJson.map((json) => NoteModel.fromJson(json)).toList();
      
      // Get local notes to merge with API data
      final localNotes = await _localDataSource.getCachedNotes();
      
      // Check if we have temporary notes that need syncing
      final hasTemporaryNotes = localNotes.any((note) {
        final isTemporaryNote = note.id.length > 10 && 
                                RegExp(r'^\d+$').hasMatch(note.id);
        return isTemporaryNote;
      });
      
      // Only sync if we have temporary notes AND haven't synced in this session
      if (hasTemporaryNotes && !_hasSyncedInThisSession) {
        print('🔄 Found temporary notes, starting sync...');
        _hasSyncedInThisSession = true; // Mark as synced
        try {
          await _syncLocalChangesToApi(localNotes, apiNotes);
          
          // After sync, get fresh data from API
          final freshNotesJson = await _apiService.getNotes();
          final freshApiNotes = freshNotesJson.map((json) => NoteModel.fromJson(json)).toList();
          
          // Get updated local notes after sync (should have cleaned up temporary notes)
          final updatedLocalNotes = await _localDataSource.getCachedNotes();
          print('📦 Found ${updatedLocalNotes.length} notes in local storage after sync');
          
          // Filter out temporary notes from local notes (they should be synced already)
          final filteredLocalNotes = updatedLocalNotes.where((note) {
            final isTemporaryNote = note.id.length > 10 && 
                                    RegExp(r'^\d+$').hasMatch(note.id);
            if (isTemporaryNote) {
              print('⚠️ WARNING: Found temporary note that should have been synced: ${note.title} (${note.id})');
            }
            return !isTemporaryNote; // Keep only non-temporary notes
          }).toList();
          
          print('🔍 After filtering: ${filteredLocalNotes.length} non-temporary local notes');
          
          // Start with fresh API notes as base
          final mergedNotes = List<NoteModel>.from(freshApiNotes);
          
          // Add only truly offline notes (not synced to API yet)
          for (final localNote in filteredLocalNotes) {
            final existsInApi = freshApiNotes.any((apiNote) => apiNote.id == localNote.id);
            if (!existsInApi) {
              mergedNotes.add(localNote);
              print('📱 Adding offline note: ${localNote.title}');
            } else {
              // Check if local note has newer changes than API
              final apiNote = freshApiNotes.firstWhere((apiNote) => apiNote.id == localNote.id);
              if (localNote.updatedAt.isAfter(apiNote.updatedAt)) {
                // Replace API note with local version (preserves local changes)
                final index = mergedNotes.indexWhere((note) => note.id == localNote.id);
                if (index != -1) {
                  mergedNotes[index] = localNote;
                  print('🔄 Keeping local version of note: ${localNote.title} (pinned: ${localNote.isPinned})');
                }
              }
            }
          }
          
          // Cache the merged notes
          await _localDataSource.cacheNotes(mergedNotes);
          
          print('🔄 Merged ${freshApiNotes.length} API notes with ${filteredLocalNotes.length} local notes = ${mergedNotes.length} total');
          return mergedNotes.map((note) => note.toEntity()).toList();
        } catch (syncError) {
          print('❌ Sync failed, returning original local notes: $syncError');
          _hasSyncedInThisSession = false; // Reset flag on failure
          // If sync fails, return the original local notes to prevent data loss
          return localNotes.map((note) => note.toEntity()).toList();
        }
      } else if (hasTemporaryNotes && _hasSyncedInThisSession) {
        print('✅ Already synced in this session, using existing data');
        // Already synced, just return the existing data
        return localNotes.map((note) => note.toEntity()).toList();
      } else {
        print('✅ No temporary notes found, using existing data');
        // No temporary notes, just return the existing data
        return localNotes.map((note) => note.toEntity()).toList();
      }
    } catch (e) {
      print('API failed, trying local storage: $e');
      // If API fails, try to get from local storage
      try {
        final cachedNotes = await _localDataSource.getCachedNotes();
        print('Found ${cachedNotes.length} cached notes');
        return cachedNotes.map((note) => note.toEntity()).toList();
      } catch (localError) {
        print('Local storage also failed: $localError');
        // Return empty list instead of throwing error
        return [];
      }
    }
  }

  @override
  Future<NoteEntity> createNote({
    required String title,
    required String content,
  }) async {
    try {
      print('🌐 Trying to create note via API...');
      // Try to create via API first
      final noteJson = await _apiService.createNote(
        title: title,
        content: content,
      );
      final note = NoteModel.fromJson(noteJson);
      
      // Cache locally
      await _localDataSource.cacheNote(note);
      print('✅ Note created via API and cached locally');
      
      return note.toEntity();
    } catch (e) {
      print('🔄 API failed, creating note locally: $e');
      // If API fails, create locally with temporary ID
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final localNote = NoteModel(
        id: tempId,
        title: title.isEmpty ? 'Untitled' : title,
        content: content.isEmpty ? ' ' : content, // Ensure content is not empty
        userId: 'local_user', // Will be updated when syncing
        isPinned: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _localDataSource.cacheNote(localNote);
      print('💾 Note created locally with ID: $tempId');
      return localNote.toEntity();
    }
  }

  @override
  Future<NoteEntity> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final noteJson = await _apiService.updateNote(
        id: id,
        title: title,
        content: content,
      );
      return NoteModel.fromJson(noteJson).toEntity();
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      print('🗑️ Trying to delete note via API: $id');
      await _apiService.deleteNote(id);
      // Also delete from local cache
      await _localDataSource.deleteNote(id);
      print('✅ Note deleted from API and local cache');
    } catch (e) {
      print('🔄 API failed, trying to delete locally: $e');
      // If API fails, delete locally
      try {
        await _localDataSource.deleteNote(id);
        print('💾 Note deleted locally');
      } catch (localError) {
        throw Exception('Failed to delete note from API and local storage: $e');
      }
    }
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query) async {
    try {
      // Try API search first
      final notesJson = await _apiService.searchNotes(query);
      return notesJson.map((json) => NoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      // If API fails, search locally
      try {
        final cachedNotes = await _localDataSource.searchNotes(query);
        return cachedNotes.map((note) => note.toEntity()).toList();
      } catch (localError) {
        throw Exception('Failed to search notes from API and local storage: $e');
      }
    }
  }

  @override
  Future<NoteEntity> togglePinNote(String id) async {
    try {
      print('🔄 Trying to toggle pin via API for note: $id');
      final noteJson = await _apiService.togglePinNote(id);
      final updatedNote = NoteModel.fromJson(noteJson);
      
      // Update local cache
      await _localDataSource.cacheNote(updatedNote);
      print('✅ Pin toggled via API and cached locally');
      
      return updatedNote.toEntity();
    } catch (e) {
      print('🔄 API failed, trying to toggle pin locally: $e');
      // If API fails, try to toggle locally (for offline notes)
      try {
        final cachedNotes = await _localDataSource.getCachedNotes();
        final noteIndex = cachedNotes.indexWhere((note) => note.id == id);
        
        if (noteIndex == -1) {
          throw Exception('Note not found locally');
        }
        
        final note = cachedNotes[noteIndex];
        print('🔍 Original note pin status: ${note.isPinned}');
        final updatedNote = note.copyWith(
          isPinned: !note.isPinned,
          updatedAt: DateTime.now(),
        );
        print('🔍 Updated note pin status: ${updatedNote.isPinned}');
        
        await _localDataSource.cacheNote(updatedNote);
        print('💾 Pin toggled locally for note: ${updatedNote.title} (pinned: ${updatedNote.isPinned})');
        
        return updatedNote.toEntity();
      } catch (localError) {
        throw Exception('Failed to toggle pin note in API and local storage: $e');
      }
    }
  }

  // Sync local changes to API
  Future<void> _syncLocalChangesToApi(List<NoteModel> localNotes, List<NoteModel> apiNotes) async {
    print('🔄 Starting sync of local changes to API...');
    
    // Track notes that were successfully synced to API
    final syncedNoteIds = <String>[];
    
    for (final localNote in localNotes) {
      // Check if this is a temporary offline note (starts with timestamp)
      final isTemporaryNote = localNote.id.length > 10 && 
                              RegExp(r'^\d+$').hasMatch(localNote.id);
      
      if (isTemporaryNote) {
        print('📤 Syncing new offline note: ${localNote.title} (temp ID: ${localNote.id})');
        try {
          final newNoteJson = await _apiService.createNote(
            title: localNote.title,
            content: localNote.content,
            isPinned: localNote.isPinned,
          );
          final newNote = NoteModel.fromJson(newNoteJson);
          
          print('🔄 Created note in API with ID: ${newNote.id}');
          
          // First add the new note with API ID
          await _localDataSource.cacheNote(newNote);
          print('💾 Cached new note with API ID: ${newNote.id}');
          
          // Then delete the old temporary note (only after successful API creation)
          await _localDataSource.deleteNote(localNote.id);
          print('🗑️ Deleted temporary note: ${localNote.id}');
          
          // Mark as synced
          syncedNoteIds.add(localNote.id);
          
          print('✅ Offline note synced to API with new ID: ${newNote.id}');
        } catch (e) {
          print('❌ Failed to sync offline note: $e');
          print('⚠️ Keeping temporary note in local storage due to sync failure');
          // Don't delete the temporary note if sync failed
        }
      } else {
        // Check if this note exists in API
        final apiNote = apiNotes.firstWhere(
          (note) => note.id == localNote.id,
          orElse: () => NoteModel(
            id: '',
            title: '',
            content: '',
            userId: '',
            isPinned: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (apiNote.id.isEmpty) {
          print('📤 Syncing new offline note: ${localNote.title}');
          try {
            final newNoteJson = await _apiService.createNote(
              title: localNote.title,
              content: localNote.content,
              isPinned: localNote.isPinned,
            );
            final newNote = NoteModel.fromJson(newNoteJson);
            
            // First add the new note with API ID
            await _localDataSource.cacheNote(newNote);
            print('💾 Cached new note with API ID: ${newNote.id}');
            
            // Then delete the old note (only after successful API creation)
            await _localDataSource.deleteNote(localNote.id);
            print('🗑️ Deleted old note: ${localNote.id}');
            
            // Mark as synced
            syncedNoteIds.add(localNote.id);
            
            print('✅ Offline note synced to API with new ID: ${newNote.id}');
          } catch (e) {
            print('❌ Failed to sync offline note: $e');
            print('⚠️ Keeping original note in local storage due to sync failure');
            // Don't delete the original note if sync failed
          }
        } else {
          // Check if local note has changes compared to API
          if (localNote.updatedAt.isAfter(apiNote.updatedAt) || 
              localNote.isPinned != apiNote.isPinned) {
            print('📤 Syncing changes for note: ${localNote.title} (pinned: ${localNote.isPinned})');
            try {
              await _apiService.updateNote(
                id: localNote.id,
                title: localNote.title,
                content: localNote.content,
                isPinned: localNote.isPinned,
              );
              print('✅ Note changes synced to API');
            } catch (e) {
              print('❌ Failed to sync note changes: $e');
            }
          }
        }
      }
    }
    
    print('🔄 Sync completed. Synced ${syncedNoteIds.length} notes.');
  }
}