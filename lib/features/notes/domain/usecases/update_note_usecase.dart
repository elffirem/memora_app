import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<NoteEntity> call({required String id, required String title, required String content}) {
    return repository.updateNote(id: id, title: title, content: content);
  }
}



