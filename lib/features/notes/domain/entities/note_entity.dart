class NoteEntity {
  final String id;
  final String title;
  final String content;
  final String? summary;  // YENİ ALAN
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    this.summary,  // YENİ ALAN
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,  // YENİ ALAN
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,  // YENİ ALAN
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}



