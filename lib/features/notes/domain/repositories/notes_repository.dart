import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> createNote({
    required String title, 
    required String content,
    bool isPinned = false,
  });
  Future<NoteEntity> updateNote({required String id, required String title, required String content});
  Future<void> deleteNote(String id);
  Future<NoteEntity> togglePinNote(String id);
  Future<List<NoteEntity>> searchNotes(String query);
  Future<NoteEntity> summarizeNote(String id);  // YENİ METHOD
  Future<void> clearAllNotes(); // YENİ METHOD
}



