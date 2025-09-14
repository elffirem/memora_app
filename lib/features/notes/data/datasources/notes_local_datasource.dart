import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getCachedNotes();
  Future<void> cacheNotes(List<NoteModel> notes);
  Future<void> cacheNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<List<NoteModel>> searchNotes(String query);
  Future<void> clearAllNotes(); // YENİ METOD
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  static const String boxName = 'notes';
  
  Box get _box => Hive.box(boxName);

  @override
  Future<List<NoteModel>> getCachedNotes() async {
    try {
      final notesMap = _box.toMap();
      print('📦 Found ${notesMap.length} notes in local storage');
      if (notesMap.isEmpty) {
        print('📭 Local storage is empty');
        return [];
      }
      
      final notes = notesMap.values
          .map((noteMap) => NoteModel.fromHive(Map<String, dynamic>.from(noteMap)))
          .toList();
      
      // Sort: pinned notes first, then by updated date
      notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      
      print('📋 Returning ${notes.length} sorted notes from local storage');
      for (final note in notes) {
        print('  - ${note.title} (${note.id})');
      }
      
      return notes;
    } catch (e) {
      print('❌ Error getting cached notes: $e');
      return [];
    }
  }

  @override
  Future<void> cacheNotes(List<NoteModel> notes) async {
    try {
      print('📦 Caching ${notes.length} notes to local storage');
      await _box.clear();
      print('🧹 Cleared local storage');
      
      for (final note in notes) {
        await _box.put(note.id, note.toHive());
        print('💾 Cached: ${note.title} (${note.id})');
      }
      
      print('✅ Successfully cached all notes');
    } catch (e) {
      print('❌ Error caching notes: $e');
    }
  }

  @override
  Future<void> cacheNote(NoteModel note) async {
    try {
      print('💾 Caching note locally: ${note.title} (ID: ${note.id})');
      await _box.put(note.id, note.toHive());
      print('✅ Note cached successfully');
    } catch (e) {
      print('❌ Error caching note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      print('🗑️ Attempting to delete note from local storage: $id');
      final existed = _box.containsKey(id);
      print('🔍 Note existed in local storage: $existed');
      
      await _box.delete(id);
      
      final stillExists = _box.containsKey(id);
      print('✅ Note deletion result - still exists: $stillExists');
    } catch (e) {
      print('❌ Error deleting note: $e');
    }
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

  @override
  Future<void> clearAllNotes() async {
    try {
      print('🧹 Clearing all notes from local storage...');
      await _box.clear();
      print('✅ Local storage cleared successfully');
    } catch (e) {
      print('❌ Error clearing local storage: $e');
    }
  }
}



