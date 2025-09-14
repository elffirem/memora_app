import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../pages/note_editor_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class NotesHomeViewModel {
  final BuildContext context;

  NotesHomeViewModel({required this.context});

  // Navigate to note editor
  void navigateToNoteEditor([NoteEntity? note]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(note: note),
      ),
    );
  }

  // Handle note search
  void searchNotes(String query) {
    context.read<NotesBloc>().add(NotesSearchRequested(query));
  }

  // Handle note deletion
  void deleteNote(String noteId) {
    context.read<NotesBloc>().add(NotesDeleteRequested(noteId));
  }

  // Handle note pin toggle
  void togglePinNote(String noteId) {
    context.read<NotesBloc>().add(NotesTogglePinRequested(noteId));
  }

  // Undo note deletion
  void undoDeleteNote(NoteEntity note) {
    context.read<NotesBloc>().add(NotesUndoDeleteRequested(note));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // Show delete confirmation snackbar
  void showDeleteSnackbar(NoteEntity note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                '"${note.title}" → VOID',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            CustomButton(
              text: 'RESTORE',
              onPressed: () => undoDeleteNote(note),
              isGradient: true,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.05,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.backgroundCard, width: 1),
        ),
        margin: const EdgeInsets.all(24),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Load notes
  void loadNotes() {
    context.read<NotesBloc>().add(NotesLoadRequested());
  }

  // Get current notes state
  NotesState getCurrentState() {
    return context.read<NotesBloc>().state;
  }

  // Check if notes are loading
  bool isLoading() {
    final state = getCurrentState();
    return state is NotesLoading;
  }

  // Get notes list
  List<NoteEntity> getNotes() {
    final state = getCurrentState();
    if (state is NotesLoaded) {
      return state.notes;
    }
    return [];
  }

  // Get search query
  String getSearchQuery() {
    final state = getCurrentState();
    if (state is NotesLoaded) {
      return state.searchQuery;
    }
    return '';
  }

  // Check if there's a recently deleted note
  NoteEntity? getRecentlyDeletedNote() {
    final state = getCurrentState();
    if (state is NotesLoaded) {
      return state.recentlyDeletedNote;
    }
    return null;
  }
}
