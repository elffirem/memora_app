import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/toggle_pin_note_usecase.dart';
import '../../domain/usecases/summarize_note_usecase.dart';
import '../../domain/usecases/clear_all_notes_usecase.dart';
import 'notes_event.dart';
import 'notes_state.dart';

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final TogglePinNoteUseCase togglePinNoteUseCase;
  final SummarizeNoteUseCase summarizeNoteUseCase;
  final ClearAllNotesUseCase clearAllNotesUseCase;

  NotesBloc({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.togglePinNoteUseCase,
    required this.summarizeNoteUseCase,
    required this.clearAllNotesUseCase,
  }) : super(NotesInitial()) {
    on<NotesLoadRequested>(_onNotesLoadRequested);
    on<NotesSearchRequested>(_onNotesSearchRequested);
    on<NotesCreateRequested>(_onNotesCreateRequested);
    on<NotesBulkCreateRequested>(_onNotesBulkCreateRequested);
    on<NotesClearAllRequested>(_onNotesClearAllRequested);
    on<NotesUpdateRequested>(_onNotesUpdateRequested);
    on<NotesDeleteRequested>(_onNotesDeleteRequested);
    on<NotesUndoDeleteRequested>(_onNotesUndoDeleteRequested);
    on<NotesTogglePinRequested>(_onNotesTogglePinRequested);
    on<NotesSummarizeRequested>(_onNotesSummarizeRequested);
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
    if (state is! NotesLoaded) return;
    final currentState = state as NotesLoaded;
    
    try {
      final newNote = await createNoteUseCase(title: event.title, content: event.content, isPinned: false);
      
      final updatedNotes = List<NoteEntity>.from(currentState.notes);
      updatedNotes.add(newNote);
      final sortedNotes = _sortNotes(updatedNotes);
      
      final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      updatedFilteredNotes.add(newNote);
      final sortedFilteredNotes = _sortNotes(updatedFilteredNotes);
      
      emit(currentState.copyWith(
        notes: sortedNotes,
        filteredNotes: sortedFilteredNotes,
      ));
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesBulkCreateRequested(
    NotesBulkCreateRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoaded) return;
    final currentState = state as NotesLoaded;
    
    try {
      final newNotes = <NoteEntity>[];
      
      for (int i = 0; i < event.notes.length; i++) {
        final noteData = event.notes[i];
        try {
          final newNote = await createNoteUseCase(
            title: noteData['title'] ?? 'Untitled', 
            content: noteData['content'] ?? '', 
            isPinned: false
          );
          newNotes.add(newNote);
        } catch (e) {
          // Continue with other notes if one fails
        }
      }
      
      // Add all new notes to the current list
      final updatedNotes = List<NoteEntity>.from(currentState.notes);
      updatedNotes.addAll(newNotes);
      final sortedNotes = _sortNotes(updatedNotes);
      
      final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      updatedFilteredNotes.addAll(newNotes);
      final sortedFilteredNotes = _sortNotes(updatedFilteredNotes);
      
      emit(currentState.copyWith(
        notes: sortedNotes,
        filteredNotes: sortedFilteredNotes,
      ));
      
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesClearAllRequested(
    NotesClearAllRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await clearAllNotesUseCase();
      emit(NotesLoaded(notes: [], filteredNotes: []));
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesUpdateRequested(
    NotesUpdateRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoaded) return;
    
    final currentState = state as NotesLoaded;
    
    // Find the note to update
    final noteIndex = currentState.notes.indexWhere((note) => note.id == event.id);
    if (noteIndex == -1) return;
    
    final noteToUpdate = currentState.notes[noteIndex];
    
    // Update the note in the list immediately
    final updatedNote = noteToUpdate.copyWith(
      title: event.title,
      content: event.content,
      updatedAt: DateTime.now(),
    );
    
    final updatedNotes = List<NoteEntity>.from(currentState.notes);
    updatedNotes[noteIndex] = updatedNote;
    
    // Update filtered notes as well
    final filteredNoteIndex = currentState.filteredNotes.indexWhere((note) => note.id == event.id);
    final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
    if (filteredNoteIndex != -1) {
      updatedFilteredNotes[filteredNoteIndex] = updatedNote;
    }
    
    // Sort notes (pinned first)
    final sortedNotes = _sortNotes(updatedNotes);
    final sortedFilteredNotes = _sortNotes(updatedFilteredNotes);
    
    // Emit updated state immediately (no loading)
    emit(currentState.copyWith(
      notes: sortedNotes,
      filteredNotes: sortedFilteredNotes,
    ));
    
    // Perform the actual update in background
    try {
      await updateNoteUseCase(id: event.id, title: event.title, content: event.content);
    } catch (e) {
      // Revert the change if it failed
      final revertedNotes = List<NoteEntity>.from(currentState.notes);
      final revertedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      
      emit(currentState.copyWith(
        notes: revertedNotes,
        filteredNotes: revertedFilteredNotes,
      ));
      
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesDeleteRequested(
    NotesDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoaded) return;
    
    final currentState = state as NotesLoaded;
    
    // Find the note to delete
    final noteIndex = currentState.notes.indexWhere((note) => note.id == event.id);
    if (noteIndex == -1) return;
    
    final noteToDelete = currentState.notes[noteIndex];
    
    // Remove the note from the list immediately
    final updatedNotes = List<NoteEntity>.from(currentState.notes);
    updatedNotes.removeAt(noteIndex);
    
    // Update filtered notes as well
    final filteredNoteIndex = currentState.filteredNotes.indexWhere((note) => note.id == event.id);
    final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
    if (filteredNoteIndex != -1) {
      updatedFilteredNotes.removeAt(filteredNoteIndex);
    }
    
    // Emit updated state immediately (no loading)
    emit(currentState.copyWith(
      notes: updatedNotes,
      filteredNotes: updatedFilteredNotes,
      recentlyDeletedNote: noteToDelete, // Store for undo functionality
    ));
    
    // Perform the actual delete in background
    try {
      await deleteNoteUseCase(event.id);
      
      // Clear the recently deleted note after successful delete (after 4 seconds)
      Future.delayed(const Duration(seconds: 4), () {
        if (!emit.isDone && state is NotesLoaded) {
          final currentState = state as NotesLoaded;
          emit(currentState.copyWith(clearRecentlyDeletedNote: true));
        }
      });
    } catch (e) {
      // Revert the change if it failed
      final revertedNotes = List<NoteEntity>.from(currentState.notes);
      final revertedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      
      emit(currentState.copyWith(
        notes: revertedNotes,
        filteredNotes: revertedFilteredNotes,
        clearRecentlyDeletedNote: true,
      ));
      
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onNotesUndoDeleteRequested(
    NotesUndoDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoaded) return;
    
    final currentState = state as NotesLoaded;
    
    // First, restore the note in backend
    try {
      final restoredNote = await createNoteUseCase(
        title: event.note.title, 
        content: event.note.content,
        isPinned: event.note.isPinned,
      );
      
      // Add the restored note (with new ID from backend) to the list
      final updatedNotes = List<NoteEntity>.from(currentState.notes);
      updatedNotes.add(restoredNote);
      
      // Sort notes (pinned first)
      final sortedNotes = _sortNotes(updatedNotes);
      
      // Update filtered notes as well
      final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      updatedFilteredNotes.add(restoredNote);
      final sortedFilteredNotes = _sortNotes(updatedFilteredNotes);
      
      // Emit updated state with the restored note
      emit(currentState.copyWith(
        notes: sortedNotes,
        filteredNotes: sortedFilteredNotes,
        clearRecentlyDeletedNote: true, // Clear the recently deleted note
      ));
      
    } catch (e) {
      // If backend restore fails, still add to UI but with original note
      final updatedNotes = List<NoteEntity>.from(currentState.notes);
      updatedNotes.add(event.note);
      
      // Sort notes (pinned first)
      final sortedNotes = _sortNotes(updatedNotes);
      
      // Update filtered notes as well
      final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      updatedFilteredNotes.add(event.note);
      final sortedFilteredNotes = _sortNotes(updatedFilteredNotes);
      
      // Emit updated state with the original note
      emit(currentState.copyWith(
        notes: sortedNotes,
        filteredNotes: sortedFilteredNotes,
        clearRecentlyDeletedNote: true, // Clear the recently deleted note
      ));
    }
  }

  void _onNotesTogglePinRequested(
    NotesTogglePinRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoaded) return;
    
    final currentState = state as NotesLoaded;
    
    // Find the note and toggle its pin status immediately in UI
    final noteIndex = currentState.notes.indexWhere((note) => note.id == event.id);
    if (noteIndex == -1) return;
    
    final note = currentState.notes[noteIndex];
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    
    // Update the notes list immediately
    final updatedNotes = List<NoteEntity>.from(currentState.notes);
    updatedNotes[noteIndex] = updatedNote;
    
    // Sort notes (pinned first)
    final sortedNotes = _sortNotes(updatedNotes);
    
    // Update filtered notes as well
    final filteredNoteIndex = currentState.filteredNotes.indexWhere((note) => note.id == event.id);
    final updatedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
    if (filteredNoteIndex != -1) {
      updatedFilteredNotes[filteredNoteIndex] = updatedNote;
    }
    final sortedFilteredNotes = _sortNotes(updatedFilteredNotes);
    
    // Emit updated state immediately (no loading)
    emit(currentState.copyWith(
      notes: sortedNotes,
      filteredNotes: sortedFilteredNotes,
    ));
    
    // Perform the actual toggle in background
    try {
      await togglePinNoteUseCase(event.id);
    } catch (e) {
      // Revert the change if it failed
      final revertedNote = note.copyWith(isPinned: note.isPinned);
      final revertedNotes = List<NoteEntity>.from(currentState.notes);
      revertedNotes[noteIndex] = revertedNote;
      final sortedRevertedNotes = _sortNotes(revertedNotes);
      
      final revertedFilteredNotes = List<NoteEntity>.from(currentState.filteredNotes);
      if (filteredNoteIndex != -1) {
        revertedFilteredNotes[filteredNoteIndex] = revertedNote;
      }
      final sortedRevertedFilteredNotes = _sortNotes(revertedFilteredNotes);
      
      emit(currentState.copyWith(
        notes: sortedRevertedNotes,
        filteredNotes: sortedRevertedFilteredNotes,
      ));
      
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
        clearRecentlyDeletedNote: true,
      ));
    }
  }

  void _onNotesSummarizeRequested(
    NotesSummarizeRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state is! NotesLoaded) return;
    
    final currentState = state as NotesLoaded;
    
    try {
      final updatedNote = await summarizeNoteUseCase(event.id);
      
      // Update the note in the list
      final updatedNotes = currentState.notes.map((note) {
        if (note.id == event.id) {
          return updatedNote;
        }
        return note;
      }).toList();
      
      final updatedFilteredNotes = currentState.filteredNotes.map((note) {
        if (note.id == event.id) {
          return updatedNote;
        }
        return note;
      }).toList();
      
      emit(currentState.copyWith(
        notes: updatedNotes,
        filteredNotes: updatedFilteredNotes,
      ));
    } catch (e) {
      emit(NotesError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}