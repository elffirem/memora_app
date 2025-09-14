import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> createNote(String title, String content);
  Future<NoteModel> updateNote(String id, String title, String content);
  Future<void> deleteNote(String id);
  Future<NoteModel> togglePinNote(String id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final Dio dio;
  final String baseUrl = 'http://localhost:8000'; // Replace with your API URL
  
  NotesRemoteDataSourceImpl(this.dio);

  String? get _authToken => FirebaseAuth.instance.currentUser?.uid;
  
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_authToken',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await dio.get(
        '$baseUrl/notes',
        options: Options(headers: _headers),
      );
      
      final List<dynamic> data = response.data;
      return data.map((json) => NoteModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch notes: ${e.message}');
    }
  }

  @override
  Future<NoteModel> createNote(String title, String content) async {
    try {
      final response = await dio.post(
        '$baseUrl/notes',
        data: {
          'title': title,
          'content': content,
        },
        options: Options(headers: _headers),
      );
      
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create note: ${e.message}');
    }
  }

  @override
  Future<NoteModel> updateNote(String id, String title, String content) async {
    try {
      final response = await dio.put(
        '$baseUrl/notes/$id',
        data: {
          'title': title,
          'content': content,
        },
        options: Options(headers: _headers),
      );
      
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update note: ${e.message}');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await dio.delete(
        '$baseUrl/notes/$id',
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw Exception('Failed to delete note: ${e.message}');
    }
  }

  @override
  Future<NoteModel> togglePinNote(String id) async {
    try {
      final response = await dio.patch(
        '$baseUrl/notes/$id/toggle-pin',
        options: Options(headers: _headers),
      );
      
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to toggle pin: ${e.message}');
    }
  }
}



