import '../repositories/notes_repository.dart';

class ClearAllNotesUseCase {
  final NotesRepository repository;

  ClearAllNotesUseCase(this.repository);

  Future<void> call() {
    return repository.clearAllNotes();
  }
}
