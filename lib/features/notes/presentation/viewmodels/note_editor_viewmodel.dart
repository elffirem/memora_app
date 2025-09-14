import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_event.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_state.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class NoteEditorViewModel {
  final BuildContext context;
  final NoteEntity? note;

  NoteEditorViewModel({
    required this.context,
    this.note,
  });

  // Initialize editor with note data
  void initializeEditor() {
    context.read<NotesBloc>().add(
      NotesEditorInitialized(
        initialTitle: note?.title,
        initialContent: note?.content,
      ),
    );
  }

  // Handle text changes
  void onTextChanged(String title, String content) {
    context.read<NotesBloc>().add(
      NotesEditorTextChanged(
        title: title,
        content: content,
      ),
    );
  }

  // Save note
  void saveNote() {
    final state = context.read<NotesBloc>().state;
    if (state is! NotesLoaded) return;
    
    final title = state.editorTitle.trim();
    final content = state.editorContent.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    if (note == null) {
      // Create new note
      context.read<NotesBloc>().add(
        NotesCreateRequested(title: title, content: content),
      );
      // Reset editor state and pop immediately for create
      context.read<NotesBloc>().add(NotesEditorReset());
      Navigator.of(context).pop();
    } else {
      // Update existing note
      context.read<NotesBloc>().add(
        NotesUpdateRequested(
          id: note!.id,
          title: title,
          content: content,
        ),
      );
      // Reset editor state and pop immediately for update
      context.read<NotesBloc>().add(NotesEditorReset());
      Navigator.of(context).pop();
    }
  }

  // Handle back navigation with unsaved changes dialog
  Future<bool> handleBack() async {
    final state = context.read<NotesBloc>().state;
    final hasChanges = state is NotesLoaded ? state.hasEditorChanges : false;
    
    if (hasChanges) {
      final shouldSave = await _showUnsavedChangesDialog();
      
      if (shouldSave == true) {
        saveNote();
        return false; // Don't pop yet, let save handle it
      } else {
        // Reset editor state when discarding
        context.read<NotesBloc>().add(NotesEditorReset());
      }
    }

    return true;
  }

  // Show unsaved changes dialog
  Future<bool?> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.backgroundCard, width: 1),
        ),
        title: Text(
          'SAVE CHANGES?',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: 0.02,
          ),
        ),
        content: Text(
          'You have unsaved changes. Do you want to save them?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          CyberpunkSecondaryButton(
            text: 'DISCARD',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CyberpunkSaveButton(
            text: 'SAVE',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  // Check if there are unsaved changes
  bool hasUnsavedChanges() {
    final state = context.read<NotesBloc>().state;
    return state is NotesLoaded ? state.hasEditorChanges : false;
  }

  // Get current editor title
  String getEditorTitle() {
    final state = context.read<NotesBloc>().state;
    return state is NotesLoaded ? state.editorTitle : '';
  }

  // Get current editor content
  String getEditorContent() {
    final state = context.read<NotesBloc>().state;
    return state is NotesLoaded ? state.editorContent : '';
  }
}
