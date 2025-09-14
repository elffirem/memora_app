import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

// Events
abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesLoadRequested extends NotesEvent {}

class NotesSearchRequested extends NotesEvent {
  final String query;

  NotesSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class NotesCreateRequested extends NotesEvent {
  final String title;
  final String content;

  NotesCreateRequested({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class NotesBulkCreateRequested extends NotesEvent {
  final List<Map<String, String>> notes; // [{title: "...", content: "..."}, ...]

  NotesBulkCreateRequested({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class NotesClearAllRequested extends NotesEvent {}

class NotesUpdateRequested extends NotesEvent {
  final String id;
  final String title;
  final String content;

  NotesUpdateRequested({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class NotesDeleteRequested extends NotesEvent {
  final String id;

  NotesDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class NotesUndoDeleteRequested extends NotesEvent {
  final NoteEntity note;

  NotesUndoDeleteRequested(this.note);

  @override
  List<Object?> get props => [note];
}

class NotesTogglePinRequested extends NotesEvent {
  final String id;

  NotesTogglePinRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class NotesSummarizeRequested extends NotesEvent {
  final String id;

  NotesSummarizeRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class NotesEditorTextChanged extends NotesEvent {
  final String title;
  final String content;

  NotesEditorTextChanged({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class NotesEditorInitialized extends NotesEvent {
  final String? initialTitle;
  final String? initialContent;

  NotesEditorInitialized({this.initialTitle, this.initialContent});

  @override
  List<Object?> get props => [initialTitle, initialContent];
}

class NotesEditorReset extends NotesEvent {}

class NotesNoteDeleted extends NotesEvent {
  final NoteEntity note;

  NotesNoteDeleted(this.note);

  @override
  List<Object?> get props => [note];
}

class NotesUndoDelete extends NotesEvent {}
