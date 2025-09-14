import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> createNote(String title, String content);
  Future<NoteEntity> updateNote(String id, String title, String content);
  Future<void> deleteNote(String id);
  Future<NoteEntity> togglePinNote(String id);
  Future<List<NoteEntity>> searchNotes(String query);
}



