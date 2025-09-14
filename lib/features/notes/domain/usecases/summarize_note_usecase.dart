import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class SummarizeNoteUseCase {
  final NotesRepository repository;

  SummarizeNoteUseCase(this.repository);

  Future<NoteEntity> call(String noteId) async {
    return await repository.summarizeNote(noteId);
  }
}
