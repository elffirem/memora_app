import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class CreateNoteUseCase {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  Future<NoteEntity> call({required String title, required String content}) {
    return repository.createNote(title: title, content: content);
  }
}



