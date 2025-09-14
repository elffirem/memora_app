import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../models/note_model.dart';
import '../../../../core/services/notes_api_service.dart';
import '../datasources/notes_local_datasource.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesApiService _apiService;
  final NotesLocalDataSource _localDataSource;

  NotesRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      print('🌐 Fetching notes from API...');
      // Try to fetch from API first
      final notesJson = await _apiService.getNotes();
      final apiNotes = notesJson.map((json) => NoteModel.fromJson(json)).toList();
      
      print('📦 Received ${apiNotes.length} notes from API');
      
      // Cache the API notes locally
      await _localDataSource.cacheNotes(apiNotes);
      print('💾 Cached API notes locally');
      
      // Get local notes to check for temporary notes that need syncing
      final localNotes = await _localDataSource.getCachedNotes();
      
      // Check if we have temporary notes that need syncing
      final temporaryNotes = localNotes.where((note) {
        final isTemporaryNote = note.id.length > 10 && 
                                RegExp(r'^\d+$').hasMatch(note.id);
        return isTemporaryNote;
      }).toList();
      
      if (temporaryNotes.isNotEmpty) {
        print('🔄 Found ${temporaryNotes.length} temporary notes, syncing...');
        try {
          await _syncLocalChangesToApi(temporaryNotes, apiNotes);
          print('✅ Temporary notes synced successfully');
          
          // After sync, get fresh data from API again
          final freshNotesJson = await _apiService.getNotes();
          final freshApiNotes = freshNotesJson.map((json) => NoteModel.fromJson(json)).toList();
          
          // Cache the fresh API notes
          await _localDataSource.cacheNotes(freshApiNotes);
          
          print('📦 Final result: ${freshApiNotes.length} notes from API');
          return freshApiNotes.map((note) => note.toEntity()).toList();
        } catch (syncError) {
          print('❌ Sync failed: $syncError');
          // If sync fails, return API notes anyway
          return apiNotes.map((note) => note.toEntity()).toList();
        }
      } else {
        print('✅ No temporary notes found, returning API notes');
        return apiNotes.map((note) => note.toEntity()).toList();
      }
    } catch (e) {
      print('❌ Failed to get notes from API: $e');
      // If API fails, try to get from local storage
      try {
        final localNotes = await _localDataSource.getCachedNotes();
        print('📱 Using ${localNotes.length} cached notes as fallback');
        return localNotes.map((note) => note.toEntity()).toList();
      } catch (localError) {
        print('❌ Local storage also failed: $localError');
        return [];
      }
    }
  }

  @override
  Future<NoteEntity> createNote({
    required String title,
    required String content,
    bool isPinned = false,
  }) async {
    try {
      print('🌐 Trying to create note via API...');
      // Try to create via API first
      final noteJson = await _apiService.createNote(
        title: title,
        content: content,
        isPinned: isPinned,
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
        isPinned: isPinned,
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
      print('🌐 Trying to update note via API: $id');
      final noteJson = await _apiService.updateNote(
        id: id,
        title: title,
        content: content,
      );
      final updatedNote = NoteModel.fromJson(noteJson);
      
      // Cache the updated note locally
      await _localDataSource.cacheNote(updatedNote);
      print('✅ Note updated via API and cached locally');
      
      return updatedNote.toEntity();
    } catch (e) {
      print('❌ API update failed: $e');
      // If API fails, update locally
      try {
        final localNotes = await _localDataSource.getCachedNotes();
        final localNote = localNotes.firstWhere(
          (note) => note.id == id,
          orElse: () => throw Exception('Note not found locally'),
        );
        
        final updatedLocalNote = localNote.copyWith(
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        );
        
        await _localDataSource.cacheNote(updatedLocalNote);
        print('💾 Note updated locally due to API failure');
        
        return updatedLocalNote.toEntity();
      } catch (localError) {
        print('❌ Local update also failed: $localError');
        throw Exception('Failed to update note: $e');
      }
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      print('🗑️ Trying to delete note via API: $id');
      await _apiService.deleteNote(id);
      
      // Also delete from local storage
      await _localDataSource.deleteNote(id);
      print('✅ Note deleted from API and local storage');
    } catch (e) {
      print('❌ API delete failed: $e');
      // If API fails, still delete locally
      try {
        await _localDataSource.deleteNote(id);
        print('💾 Note deleted from local storage only');
      } catch (localError) {
        print('❌ Local delete also failed: $localError');
        throw Exception('Failed to delete note: $e');
      }
    }
  }

  @override
  Future<NoteEntity> togglePinNote(String id) async {
    try {
      print('📌 Trying to toggle pin via API: $id');
      final noteJson = await _apiService.togglePinNote(id);
      final updatedNote = NoteModel.fromJson(noteJson);
      
      // Cache the updated note locally
      await _localDataSource.cacheNote(updatedNote);
      print('✅ Pin toggled via API and cached locally');
      
      return updatedNote.toEntity();
    } catch (e) {
      print('❌ API toggle pin failed: $e');
      // If API fails, toggle locally
      try {
        final localNotes = await _localDataSource.getCachedNotes();
        final localNote = localNotes.firstWhere(
          (note) => note.id == id,
          orElse: () => throw Exception('Note not found locally'),
        );
        
        final updatedLocalNote = localNote.copyWith(
          isPinned: !localNote.isPinned,
          updatedAt: DateTime.now(),
        );
        
        await _localDataSource.cacheNote(updatedLocalNote);
        print('💾 Pin toggled locally due to API failure');
        
        return updatedLocalNote.toEntity();
      } catch (localError) {
        print('❌ Local toggle pin also failed: $localError');
        throw Exception('Failed to toggle pin: $e');
      }
    }
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query) async {
    try {
      print('🔍 Searching notes via API: $query');
      final notesJson = await _apiService.searchNotes(query);
      final notes = notesJson.map((json) => NoteModel.fromJson(json)).toList();
      
      print('📦 Found ${notes.length} notes matching query');
      return notes.map((note) => note.toEntity()).toList();
    } catch (e) {
      print('❌ API search failed: $e');
      // If API fails, search locally
      try {
        final localNotes = await _localDataSource.getCachedNotes();
        final filteredNotes = localNotes.where((note) {
          return note.title.toLowerCase().contains(query.toLowerCase()) ||
                 note.content.toLowerCase().contains(query.toLowerCase());
        }).toList();
        
        print('📱 Found ${filteredNotes.length} local notes matching query');
        return filteredNotes.map((note) => note.toEntity()).toList();
      } catch (localError) {
        print('❌ Local search also failed: $localError');
        return [];
      }
    }
  }

  // Sync local changes to API
  Future<void> _syncLocalChangesToApi(List<NoteModel> temporaryNotes, List<NoteModel> apiNotes) async {
    print('🔄 Starting sync of temporary notes to API...');
    
    for (final tempNote in temporaryNotes) {
      print('📤 Syncing temporary note: ${tempNote.title} (temp ID: ${tempNote.id})');
      try {
        final newNoteJson = await _apiService.createNote(
          title: tempNote.title,
          content: tempNote.content,
          isPinned: tempNote.isPinned,
        );
        final newNote = NoteModel.fromJson(newNoteJson);
        
        print('🔄 Created note in API with ID: ${newNote.id}');
        
        // Cache the new note with API ID
        await _localDataSource.cacheNote(newNote);
        print('💾 Cached new note with API ID: ${newNote.id}');
        
        // Delete the temporary note
        await _localDataSource.deleteNote(tempNote.id);
        print('🗑️ Deleted temporary note: ${tempNote.id}');
        
        print('✅ Temporary note synced to API with new ID: ${newNote.id}');
      } catch (e) {
        print('❌ Failed to sync temporary note: $e');
        print('⚠️ Keeping temporary note in local storage due to sync failure');
        // Don't delete the temporary note if sync failed
      }
    }
    
    print('🔄 Sync completed.');
  }

  @override
  Future<NoteEntity> summarizeNote(String id) async {
    try {
      print('🤖 Summarizing note via API: $id');
      final noteJson = await _apiService.summarizeNote(id);
      final note = NoteModel.fromJson(noteJson);
      
      // Cache the updated note locally
      await _localDataSource.cacheNote(note);
      print('✅ Note summarized and cached locally');
      
      return note.toEntity();
    } catch (e) {
      print('❌ Failed to summarize note: $e');
      throw Exception('Failed to summarize note: $e');
    }
  }

  @override
  Future<void> clearAllNotes() async {
    try {
      print('🧹 Clearing all notes from local storage...');
      await _localDataSource.clearAllNotes();
      print('✅ All notes cleared successfully');
    } catch (e) {
      print('❌ Failed to clear notes: $e');
      throw Exception('Failed to clear notes: $e');
    }
  }
}