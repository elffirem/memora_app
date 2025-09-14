import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../datasources/notes_remote_datasource.dart';
import '../models/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  NotesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      if (isConnected) {
        try {
          // Try to get notes from remote first
          final remoteNotes = await remoteDataSource.getNotes();
          
          // Cache the remote notes locally
          await localDataSource.cacheNotes(remoteNotes);
          
          return remoteNotes;
        } catch (e) {
          // If remote fails, fall back to local
          print('Remote fetch failed, using local: $e');
          final cachedNotes = await localDataSource.getCachedNotes();
          return cachedNotes;
        }
      } else {
        // Offline: return cached notes
        final cachedNotes = await localDataSource.getCachedNotes();
        return cachedNotes;
      }
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  @override
  Future<NoteEntity> createNote(String title, String content) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'local_user';
      final now = DateTime.now();
      final note = NoteModel(
        id: const Uuid().v4(),
        title: title,
        content: content,
        isPinned: false,
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );
      
      // Always cache locally first (offline-first)
      await localDataSource.cacheNote(note);
      
      // Check connectivity and sync to remote
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      if (isConnected) {
        try {
          // Try to sync to remote
          await remoteDataSource.createNote(note.title, note.content);
        } catch (e) {
          print('Remote create failed, note saved locally: $e');
          // Note is already saved locally, so we continue
        }
      }
      
      return note;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  @override
  Future<NoteEntity> updateNote(String id, String title, String content) async {
    try {
      final cachedNotes = await localDataSource.getCachedNotes();
      final existingNote = cachedNotes.firstWhere((n) => n.id == id);
      
      final updatedNote = NoteModel(
        id: existingNote.id,
        title: title,
        content: content,
        isPinned: existingNote.isPinned,
        createdAt: existingNote.createdAt,
        updatedAt: DateTime.now(),
        userId: existingNote.userId,
      );
      
      // Always update locally first (offline-first)
      await localDataSource.cacheNote(updatedNote);
      
      // Check connectivity and sync to remote
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      if (isConnected) {
        try {
          // Try to sync to remote
          await remoteDataSource.updateNote(updatedNote.id, updatedNote.title, updatedNote.content);
        } catch (e) {
          print('Remote update failed, note updated locally: $e');
          // Note is already updated locally, so we continue
        }
      }
      
      return updatedNote;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      // Always delete locally first (offline-first)
      await localDataSource.deleteNote(id);
      
      // Check connectivity and sync to remote
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      if (isConnected) {
        try {
          // Try to sync to remote
          await remoteDataSource.deleteNote(id);
        } catch (e) {
          print('Remote delete failed, note deleted locally: $e');
          // Note is already deleted locally, so we continue
        }
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  @override
  Future<NoteEntity> togglePinNote(String id) async {
    try {
      final cachedNotes = await localDataSource.getCachedNotes();
      final existingNote = cachedNotes.firstWhere((n) => n.id == id);
      
      final updatedNote = NoteModel(
        id: existingNote.id,
        title: existingNote.title,
        content: existingNote.content,
        isPinned: !existingNote.isPinned,
        createdAt: existingNote.createdAt,
        updatedAt: existingNote.updatedAt,
        userId: existingNote.userId,
      );
      
      // Always update locally first (offline-first)
      await localDataSource.cacheNote(updatedNote);
      
      // Check connectivity and sync to remote
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      if (isConnected) {
        try {
          // Try to sync to remote
          await remoteDataSource.updateNote(updatedNote.id, updatedNote.title, updatedNote.content);
        } catch (e) {
          print('Remote pin toggle failed, note updated locally: $e');
          // Note is already updated locally, so we continue
        }
      }
      
      return updatedNote;
    } catch (e) {
      throw Exception('Failed to toggle pin: $e');
    }
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query) async {
    return await localDataSource.searchNotes(query);
  }
}



