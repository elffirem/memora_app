import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  late final Dio _dio;

  NotesApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          options.headers['X-User-ID'] = user.uid;
        }
        handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } catch (e) {
      throw Exception('Backend connection failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final response = await _dio.get('/notes');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
    bool isPinned = false,
  }) async {
    try {
      final noteData = {
        'title': title.trim().isEmpty ? 'Untitled' : title.trim(),
        'content': content.trim().isEmpty ? ' ' : content.trim(), // Backend requires non-empty content
        'is_pinned': isPinned,
      };
      
      final response = await _dio.post('/notes', data: noteData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<Map<String, dynamic>> updateNote({
    required String id,
    required String title,
    required String content,
    bool? isPinned,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title.trim().isEmpty ? 'Untitled' : title.trim(),
        'content': content.trim().isEmpty ? ' ' : content.trim(), // Backend requires non-empty content
      };
      if (isPinned != null) {
        data['is_pinned'] = isPinned;
      }
      
      final response = await _dio.put('/notes/$id', data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _dio.delete('/notes/$id');
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<Map<String, dynamic>> togglePinNote(String id) async {
    try {
      final response = await _dio.patch('/notes/$id/toggle-pin');
      return response.data;
    } catch (e) {
      throw Exception('Failed to toggle pin note: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    try {
      final response = await _dio.get('/notes/search', queryParameters: {
        'q': query,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }

  Future<Map<String, dynamic>> summarizeNote(String noteId) async {
    try {
      final response = await _dio.post('/notes/$noteId/summarize');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to summarize note: $e');
    }
  }
}
