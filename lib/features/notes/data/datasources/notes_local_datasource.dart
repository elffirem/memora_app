import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getCachedNotes();
  Future<void> cacheNotes(List<NoteModel> notes);
  Future<void> cacheNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<List<NoteModel>> searchNotes(String query);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  static const String boxName = 'notes';
  
  Box get _box => Hive.box(boxName);

  @override
  Future<List<NoteModel>> getCachedNotes() async {
    final notesMap = _box.toMap();
    final notes = notesMap.values
        .map((noteMap) => NoteModel.fromHive(Map<String, dynamic>.from(noteMap)))
        .toList();
    
    // Sort: pinned notes first, then by updated date
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    
    return notes;
  }

  @override
  Future<void> cacheNotes(List<NoteModel> notes) async {
    await _box.clear();
    for (final note in notes) {
      await _box.put(note.id, note.toHive());
    }
  }

  @override
  Future<void> cacheNote(NoteModel note) async {
    await _box.put(note.id, note.toHive());
  }

  @override
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final notes = await getCachedNotes();
    if (query.isEmpty) return notes;
    
    final lowerQuery = query.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
             note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}



