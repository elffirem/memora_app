import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> createNote({required String title, required String content});
  Future<NoteEntity> updateNote({required String id, required String title, required String content});
  Future<void> deleteNote(String id);
  Future<NoteEntity> togglePinNote(String id);
  Future<List<NoteEntity>> searchNotes(String query);
}



