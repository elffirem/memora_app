import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class GetNotesUseCase {
  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  Future<List<NoteEntity>> call() {
    return repository.getNotes();
  }
}



