import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class TogglePinNoteUseCase {
  final NotesRepository repository;

  TogglePinNoteUseCase(this.repository);

  Future<NoteEntity> call(String id) async {
    return await repository.togglePinNote(id);
  }
}
