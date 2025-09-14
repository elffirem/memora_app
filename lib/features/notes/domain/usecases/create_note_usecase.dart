import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class CreateNoteUseCase {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  Future<NoteEntity> call(String title, String content) {
    return repository.createNote(title, content);
  }
}



