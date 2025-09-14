import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import 'note_card_widget.dart';
import '../pages/note_editor_page.dart';

class NotesListWidget extends StatelessWidget {
  final List<NoteEntity> notes;
  final Function(NoteEntity) onNoteDeleted;

  const NotesListWidget({
    super.key,
    required this.notes,
    required this.onNoteDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No notes found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first note or try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCardWidget(
          note: note,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NoteEditorPage(note: note),
              ),
            );
          },
          onDelete: () {
            context.read<NotesBloc>().add(NotesDeleteRequested(note.id));
            onNoteDeleted(note);
          },
          onTogglePin: () {
            context.read<NotesBloc>().add(NotesTogglePinRequested(note.id));
          },
        );
      },
    );
  }
}



