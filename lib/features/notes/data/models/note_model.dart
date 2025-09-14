import 'package:equatable/equatable.dart';
import '../../domain/entities/note_entity.dart';

class NoteModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String userId;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      userId: json['user_id'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      isPinned: isPinned,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromHive(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      userId: map['userId'] as String? ?? 'local_user',
      isPinned: map['isPinned'] as bool? ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, content, userId, isPinned, createdAt, updatedAt];
}