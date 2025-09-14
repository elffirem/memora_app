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
      final notesJson = await _apiService.getNotes();
      final apiNotes = notesJson.map((json) => NoteModel.fromJson(json)).toList();
      
      await _localDataSource.cacheNotes(apiNotes);
      
      final localNotes = await _localDataSource.getCachedNotes();
      
      final temporaryNotes = localNotes.where((note) {
        final isTemporaryNote = note.id.length > 10 && 
                                RegExp(r'^\d+$').hasMatch(note.id);
        return isTemporaryNote;
      }).toList();
      
      if (temporaryNotes.isNotEmpty) {
        try {
          await _syncLocalChangesToApi(temporaryNotes, apiNotes);
          
          final freshNotesJson = await _apiService.getNotes();
          final freshApiNotes = freshNotesJson.map((json) => NoteModel.fromJson(json)).toList();
          
          await _localDataSource.cacheNotes(freshApiNotes);
          
          return freshApiNotes.map((note) => note.toEntity()).toList();
        } catch (syncError) {
          return apiNotes.map((note) => note.toEntity()).toList();
        }
      } else {
        return apiNotes.map((note) => note.toEntity()).toList();
      }
    } catch (e) {
      try {
        final localNotes = await _localDataSource.getCachedNotes();
        return localNotes.map((note) => note.toEntity()).toList();
      } catch (localError) {
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
      final noteJson = await _apiService.createNote(
        title: title,
        content: content,
        isPinned: isPinned,
      );
      final note = NoteModel.fromJson(noteJson);
      
      await _localDataSource.cacheNote(note);
      
      return note.toEntity();
    } catch (e) {
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
      final updatedNote = NoteModel.fromJson(noteJson);
      
      await _localDataSource.cacheNote(updatedNote);
      
      return updatedNote.toEntity();
    } catch (e) {
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
        
        return updatedLocalNote.toEntity();
      } catch (localError) {
        throw Exception('Failed to update note: $e');
      }
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _apiService.deleteNote(id);
      
      // Also delete from local storage
      await _localDataSource.deleteNote(id);
    } catch (e) {
      // If API fails, still delete locally
      try {
        await _localDataSource.deleteNote(id);
      } catch (localError) {
        throw Exception('Failed to delete note: $e');
      }
    }
  }

  @override
  Future<NoteEntity> togglePinNote(String id) async {
    try {
      final noteJson = await _apiService.togglePinNote(id);
      final updatedNote = NoteModel.fromJson(noteJson);
      
      await _localDataSource.cacheNote(updatedNote);
      
      return updatedNote.toEntity();
    } catch (e) {
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
        
        return updatedLocalNote.toEntity();
      } catch (localError) {
        throw Exception('Failed to toggle pin: $e');
      }
    }
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query) async {
    try {
      final notesJson = await _apiService.searchNotes(query);
      final notes = notesJson.map((json) => NoteModel.fromJson(json)).toList();
      
      return notes.map((note) => note.toEntity()).toList();
    } catch (e) {
      // If API fails, search locally
      try {
        final localNotes = await _localDataSource.getCachedNotes();
        final filteredNotes = localNotes.where((note) {
          return note.title.toLowerCase().contains(query.toLowerCase()) ||
                 note.content.toLowerCase().contains(query.toLowerCase());
        }).toList();
        
        return filteredNotes.map((note) => note.toEntity()).toList();
      } catch (localError) {
        return [];
      }
    }
  }

  // Sync local changes to API
  Future<void> _syncLocalChangesToApi(List<NoteModel> temporaryNotes, List<NoteModel> apiNotes) async {
    for (final tempNote in temporaryNotes) {
      try {
        final newNoteJson = await _apiService.createNote(
          title: tempNote.title,
          content: tempNote.content,
          isPinned: tempNote.isPinned,
        );
        final newNote = NoteModel.fromJson(newNoteJson);
        
        // Cache the new note with API ID
        await _localDataSource.cacheNote(newNote);
        
        // Delete the temporary note
        await _localDataSource.deleteNote(tempNote.id);
      } catch (e) {
        // Don't delete the temporary note if sync failed
      }
    }
  }

  @override
  Future<NoteEntity> summarizeNote(String id) async {
    try {
      final noteJson = await _apiService.summarizeNote(id);
      final note = NoteModel.fromJson(noteJson);
      
      await _localDataSource.cacheNote(note);
      
      return note.toEntity();
    } catch (e) {
      throw Exception('Failed to summarize note: $e');
    }
  }

  @override
  Future<void> clearAllNotes() async {
    try {
      await _localDataSource.clearAllNotes();
    } catch (e) {
      throw Exception('Failed to clear notes: $e');
    }
  }
}