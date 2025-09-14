import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

// States
abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;
  final List<NoteEntity> filteredNotes;
  final String searchQuery;
  final String editorTitle;
  final String editorContent;
  final String originalEditorTitle;
  final String originalEditorContent;
  final bool hasEditorChanges;
  final NoteEntity? recentlyDeletedNote;

  NotesLoaded({
    required this.notes,
    required this.filteredNotes,
    this.searchQuery = '',
    this.editorTitle = '',
    this.editorContent = '',
    this.originalEditorTitle = '',
    this.originalEditorContent = '',
    this.hasEditorChanges = false,
    this.recentlyDeletedNote,
  });

  @override
  List<Object?> get props => [notes, filteredNotes, searchQuery, editorTitle, editorContent, originalEditorTitle, originalEditorContent, hasEditorChanges, recentlyDeletedNote];

  NotesLoaded copyWith({
    List<NoteEntity>? notes,
    List<NoteEntity>? filteredNotes,
    String? searchQuery,
    String? editorTitle,
    String? editorContent,
    String? originalEditorTitle,
    String? originalEditorContent,
    bool? hasEditorChanges,
    NoteEntity? recentlyDeletedNote,
    bool clearRecentlyDeletedNote = false,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      searchQuery: searchQuery ?? this.searchQuery,
      editorTitle: editorTitle ?? this.editorTitle,
      editorContent: editorContent ?? this.editorContent,
      originalEditorTitle: originalEditorTitle ?? this.originalEditorTitle,
      originalEditorContent: originalEditorContent ?? this.originalEditorContent,
      hasEditorChanges: hasEditorChanges ?? this.hasEditorChanges,
      recentlyDeletedNote: clearRecentlyDeletedNote ? null : (recentlyDeletedNote ?? this.recentlyDeletedNote),
    );
  }
}

class NotesError extends NotesState {
  final String message;

  NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotesOperationSuccess extends NotesState {
  final String message;
  final List<NoteEntity> notes;

  NotesOperationSuccess(this.message, this.notes);

  @override
  List<Object?> get props => [message, notes];
}
