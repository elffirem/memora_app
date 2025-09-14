import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/toggle_pin_note_usecase.dart';

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
      recentlyDeletedNote: recentlyDeletedNote ?? this.recentlyDeletedNote,
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

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final TogglePinNoteUseCase togglePinNoteUseCase;

  NotesBloc({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.togglePinNoteUseCase,
  }) : super(NotesInitial()) {
    on<NotesLoadRequested>(_onNotesLoadRequested);
    on<NotesSearchRequested>(_onNotesSearchRequested);
    on<NotesCreateRequested>(_onNotesCreateRequested);
    on<NotesUpdateRequested>(_onNotesUpdateRequested);
    on<NotesDeleteRequested>(_onNotesDeleteRequested);
    on<NotesUndoDeleteRequested>(_onNotesUndoDeleteRequested);
    on<NotesTogglePinRequested>(_onNotesTogglePinRequested);
    on<NotesEditorTextChanged>(_onNotesEditorTextChanged);
    on<NotesEditorInitialized>(_onNotesEditorInitialized);
    on<NotesEditorReset>(_onNotesEditorReset);
    on<NotesNoteDeleted>(_onNotesNoteDeleted);
    on<NotesUndoDelete>(_onNotesUndoDelete);
  }

  void _onNotesLoadRequested(
    NotesLoadRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final notes = await getNotesUseCase();
      final sortedNotes = _sortNotes(notes);
      
      if (state is NotesLoaded) {
        final currentState = state as NotesLoaded;
        emit(currentState.copyWith(
          notes: sortedNotes,
          filteredNotes: sortedNotes,
          searchQuery: '',
        ));
      } else {
        emit(NotesLoaded(notes: sortedNotes, filteredNotes: sortedNotes));
      }
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  List<NoteEntity> _sortNotes(List<NoteEntity> notes) {
    // Sort notes: pinned notes first (by updatedAt desc), then unpinned notes (by updatedAt desc)
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();
    
    // Sort pinned notes by updatedAt descending
    pinnedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    // Sort unpinned notes by updatedAt descending
    unpinnedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    // Combine: pinned first, then unpinned
    return [...pinnedNotes, ...unpinnedNotes];
  }

  void _onNotesSearchRequested(
    NotesSearchRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredNotes: currentState.notes,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.notes.where((note) {
          final query = event.query.toLowerCase();
          return note.title.toLowerCase().contains(query) ||
                 note.content.toLowerCase().contains(query);
        }).toList();
        
        // Sort filtered results as well
        final sortedFiltered = _sortNotes(filtered);
        
        emit(currentState.copyWith(
          filteredNotes: sortedFiltered,
          searchQuery: event.query,
        ));
      }
    }
  }

  void _onNotesCreateRequested(
    NotesCreateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await createNoteUseCase(event.title, event.content);
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesUpdateRequested(
    NotesUpdateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await updateNoteUseCase(event.id, event.title, event.content);
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesDeleteRequested(
    NotesDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await deleteNoteUseCase(event.id);
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesUndoDeleteRequested(
    NotesUndoDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await createNoteUseCase(event.note.title, event.note.content);
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesTogglePinRequested(
    NotesTogglePinRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await togglePinNoteUseCase(event.id);
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesEditorTextChanged(
    NotesEditorTextChanged event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      final hasChanges = event.title != currentState.originalEditorTitle || 
                        event.content != currentState.originalEditorContent;
      
      emit(currentState.copyWith(
        editorTitle: event.title,
        editorContent: event.content,
        hasEditorChanges: hasChanges,
      ));
    } else {
      // If no notes loaded yet, create a basic state for editor
      emit(NotesLoaded(
        notes: [],
        filteredNotes: [],
        editorTitle: event.title,
        editorContent: event.content,
        originalEditorTitle: '',
        originalEditorContent: '',
        hasEditorChanges: true,
      ));
    }
  }

  void _onNotesEditorInitialized(
    NotesEditorInitialized event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(
        editorTitle: event.initialTitle ?? '',
        editorContent: event.initialContent ?? '',
        originalEditorTitle: event.initialTitle ?? '',
        originalEditorContent: event.initialContent ?? '',
        hasEditorChanges: false,
      ));
    } else {
      // If no notes loaded yet, create a basic state for editor
      emit(NotesLoaded(
        notes: [],
        filteredNotes: [],
        editorTitle: event.initialTitle ?? '',
        editorContent: event.initialContent ?? '',
        originalEditorTitle: event.initialTitle ?? '',
        originalEditorContent: event.initialContent ?? '',
        hasEditorChanges: false,
      ));
    }
  }

  void _onNotesEditorReset(
    NotesEditorReset event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(
        editorTitle: '',
        editorContent: '',
        hasEditorChanges: false,
      ));
    } else {
      // If no notes loaded yet, create a basic state for editor
      emit(NotesLoaded(
        notes: [],
        filteredNotes: [],
        editorTitle: '',
        editorContent: '',
        hasEditorChanges: false,
      ));
    }
  }

  void _onNotesNoteDeleted(
    NotesNoteDeleted event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(
        recentlyDeletedNote: event.note,
      ));
    }
  }

  void _onNotesUndoDelete(
    NotesUndoDelete event,
    Emitter<NotesState> emit,
  ) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(currentState.copyWith(
        recentlyDeletedNote: null,
      ));
    }
  }
}

