import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _viewModel = NoteEditorViewModel(context: context, note: widget.note);
    
    // Initialize BLoC with initial values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initializeEditor();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
                                hintText: 'Stream consciousness data... Neural patterns will be automatically encoded and stored in the quantum memory matrix.',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildToolbarButton('◆'),
                          _buildToolbarButton('◉'),
                          _buildToolbarButton('◈'),
                          _buildToolbarButton('◇'),
                          _buildToolbarButton('⧗'),
                          _buildToolbarButton('◎'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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