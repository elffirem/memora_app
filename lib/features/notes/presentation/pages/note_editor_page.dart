import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_event.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_state.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../viewmodels/note_editor_viewmodel.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteEntity? note;

  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteEditorViewModel _viewModel;
  late ValueNotifier<bool> _canSummarizeNotifier;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _viewModel = NoteEditorViewModel(context: context, note: widget.note);
    _canSummarizeNotifier = ValueNotifier<bool>(false);

    // Add listener to update UI when content changes
    _contentController.addListener(_onContentChanged);

    // Initialize BLoC with initial values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initializeEditor();
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _canSummarizeNotifier.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final content = _contentController.text.trim();
    final canSummarize = content.length >= 100;
    _canSummarizeNotifier.value = canSummarize;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        final hasChanges = _viewModel.hasUnsavedChanges();
        final editorTitle = _viewModel.getEditorTitle();
        final editorContent = _viewModel.getEditorContent();

        // Update controllers when BLoC state changes
        if (_titleController.text != editorTitle) {
          _titleController.text = editorTitle;
        }
        if (_contentController.text != editorContent) {
          _contentController.text = editorContent;
        }

        return Scaffold(
          body: Container(
            decoration: AppTheme.backgroundGradient,
            child: Stack(
              children: [
                // Animated background constellation
                Positioned.fill(
                  child: CustomPaint(
                    painter: ConstellationPainter(),
                  ),
                ),
                // Main content
                Column(
                  children: [
                    // Custom header with cyberpunk styling
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            AppTheme.backgroundTertiary.withOpacity(0.8),
                          ],
                        ),
                        border: const Border(
                          bottom: BorderSide(color: AppTheme.backgroundCard, width: 1),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              // Back button
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.backgroundCard, width: 2),
                                ),
                                child: Center(
                                  child: InkWell(
                                    onTap: () async {
                                      final shouldPop = await _viewModel.handleBack();
                                      if (shouldPop) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text(
                                      '←',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Save button
                              if (hasChanges)
                                CyberpunkSaveButton(
                                  onPressed: _viewModel.saveNote,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Editor content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title input with cyberpunk styling
                            CyberpunkTitleField(
                              controller: _titleController,
                              hintText: 'memory.title...',
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                _viewModel.onTextChanged(value, _contentController.text);
                              },
                            ),

                            const SizedBox(height: 28),

                            // Content textarea with cyberpunk styling
                            Expanded(
                              child: CyberpunkContentField(
                                controller: _contentController,
                                hintText:
                                    'Stream consciousness data... Neural patterns will be automatically encoded and stored in the quantum memory matrix.',
                                expands: true,
                                onChanged: (value) {
                                  _viewModel.onTextChanged(_titleController.text, value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Toolbar with cyberpunk styling
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            AppTheme.backgroundTertiary.withOpacity(0.6),
                          ],
                        ),
                        border: const Border(
                          top: BorderSide(color: AppTheme.backgroundCard, width: 1),
                        ),
                      ),
                     
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: widget.note != null
              ? ValueListenableBuilder<bool>(
                  valueListenable: _canSummarizeNotifier,
                  builder: (context, canSummarize, child) {
                    return FloatingActionButton(
                      onPressed: canSummarize ? () => _showSummarizeDialog(context) : null,
                      backgroundColor: canSummarize
                          ? AppTheme.primaryOrange
                          : AppTheme.primaryOrange.withOpacity(0.3),
                      child: Icon(
                        Icons.auto_awesome,
                        color: canSummarize ? Colors.white : Colors.white.withOpacity(0.5),
                      ),
                    );
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildToolbarButton(String icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.backgroundCard, width: 2),
      ),
      child: Center(
        child: Text(
          icon,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  void _showSummarizeDialog(BuildContext context) {
    if (widget.note == null) return;

    // Check if content has at least 100 characters
    final content = _contentController.text.trim();
    if (content.length < 100) {
      _showValidationToast(context, 'Content must be at least 100 characters to summarize');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.primaryRed,
              ),
            );
          } else if (state is NotesLoaded) {
            // Check if the current note has been updated with summary
            final updatedNote = state.notes.firstWhere(
              (note) => note.id == widget.note!.id,
              orElse: () => widget.note!,
            );

            if (updatedNote.summary != null && updatedNote.summary?.isNotEmpty == true) {
              Navigator.of(context).pop();
              _showSummaryResult(context, updatedNote.summary ?? '');
            }
          }
        },
        child: AlertDialog(
          backgroundColor: AppTheme.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.backgroundCard, width: 1),
          ),
          title: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Summarization',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
              ),
              const SizedBox(height: 16),
              Text(
                'Generating summary...',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Trigger summarize event
    context.read<NotesBloc>().add(NotesSummarizeRequested(widget.note!.id));
  }

  void _showSummaryResult(BuildContext context, String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.backgroundCard, width: 1),
        ),
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryOrange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Summarization:',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Text(
              summary,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.primaryOrange, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Custom painter for animated constellation background
class ConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw constellation points
    final points = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.9),
      Offset(size.width * 0.5, size.height * 0.5),
    ];

    for (final point in points) {
      canvas.drawCircle(point, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
