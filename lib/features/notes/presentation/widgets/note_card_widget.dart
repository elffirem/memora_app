import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/note_entity.dart';
import '../../../../core/theme/app_theme.dart';

class NoteCardWidget extends StatefulWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
  });

  @override
  State<NoteCardWidget> createState() => _NoteCardWidgetState();
}

class _NoteCardWidgetState extends State<NoteCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundTertiary.withOpacity(0.8),
                  AppTheme.backgroundCard.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.note.isPinned
                    ? AppTheme.primaryOrange.withOpacity(0.5)
                    : AppTheme.primaryCyan.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                if (widget.note.isPinned)
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 140, // Minimum height for consistent card size
                  ),
                  child: Stack(
                  children: [
                    // Pin indicator for pinned notes
                    if (widget.note.isPinned)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '◆',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppTheme.primaryOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with title and actions
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.note.title.isEmpty
                                      ? 'UNTITLED'
                                      : widget.note.title.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: widget.note.title.isEmpty
                                        ? AppTheme.textMuted
                                        : AppTheme.textPrimary,
                                    letterSpacing: -0.02,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Action buttons
                              AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildActionButton(
                                      iconData: Icons.star,
                                      onTap: () {
                                        // Haptic feedback
                                        HapticFeedback.lightImpact();
                                        // Call the original callback
                                        widget.onTogglePin();
                                      },
                                      isActive: widget.note.isPinned,
                                    ),
                                    SizedBox(width: 8),
                                    _buildActionButton(
                                      iconData: Icons.delete,
                                      onTap: () {
                                        // Haptic feedback
                                        HapticFeedback.mediumImpact();
                                        // Call the original callback
                                        widget.onDelete();
                                      },
                                      isDestructive: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (widget.note.content.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              widget.note.content,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textTertiary,
                                height: 1.7,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],


                          const SizedBox(height: 18),

                          // Footer with timestamp
                          Row(
                            children: [
                              Text(
                                _formatDate(widget.note.updatedAt),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 0.05,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppTheme.textDisabled,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData iconData,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    // Renk kontrolü tek yerde
    final Color effectiveColor = isActive
        ? AppTheme.primaryOrange
        : isDestructive
            ? AppTheme.primaryRed
            : AppTheme.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryOrange.withOpacity(0.2)
              : isDestructive
                  ? AppTheme.primaryRed.withOpacity(0.1)
                  : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryOrange
                : isDestructive
                    ? AppTheme.primaryRed
                    : AppTheme.backgroundCard,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            iconData,
            size: 18,
            color: effectiveColor, // renk otomatik handle ediliyor
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm:ss').format(date);
    } else if (difference.inDays == 1) {
      return 'YESTERDAY';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date).toUpperCase();
    } else {
      return DateFormat('MMM dd').format(date).toUpperCase();
    }
  }

  String _getStatusText() {
    final now = DateTime.now();
    final difference = now.difference(widget.note.updatedAt);

    if (difference.inDays == 0) {
      return 'MODIFIED';
    } else if (difference.inDays < 7) {
      return 'ARCHIVED';
    } else {
      return 'ENCRYPTED';
    }
  }
}
