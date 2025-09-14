import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/notes_bloc.dart';
import '../widgets/notes_list_widget.dart';
import '../viewmodels/notes_home_viewmodel.dart';
import 'note_editor_page.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final TextEditingController _searchController = TextEditingController();
  late NotesHomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotesHomeViewModel(context: context);
    
    // Load notes when page initializes
    _viewModel.loadNotes();
    
    // Listen to connectivity changes
    context.read<ConnectivityService>().stream.listen((isConnected) {
      // Connectivity state is handled by the view model
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.backgroundCard, width: 2),
          ),
          title: Text(
            'DISCONNECT',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: 0.05,
            ),
          ),
          content: Text(
            'Are you sure you want to disconnect from the neural network?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'CANCEL',
                    onPressed: () => Navigator.of(context).pop(),
                    isPrimary: false,
                    isSecondary: true,
                    isGradient: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'LOGOUT',
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    isGradient: true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with title, connectivity status and logout button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // App title with gradient
                              ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                              ).createShader(bounds),
                                child: Text(
                                  'MEMORY BANK',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.03,
                                  ),
                                ),
                              ),
                              // Right side: Connectivity status and Logout button
                              Row(
                                children: [
                                  // Connectivity status
                                  BlocBuilder<ConnectivityService, bool>(
                                    builder: (context, isConnected) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: isConnected 
                                              ? LinearGradient(colors: [AppTheme.primaryCyan, AppTheme.primaryPurple])
                                              : LinearGradient(colors: [AppTheme.primaryRed, AppTheme.primaryOrange]),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isConnected ? AppTheme.primaryCyan : AppTheme.primaryRed).withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          isConnected ? 'ONLINE' : 'OFFLINE',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                            letterSpacing: 0.05,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  // Logout button
                               InkWell( //I use this inkwell + icon because IconButton has some alignment issues
                                           onTap: () => _showLogoutDialog(context),
                                            child: Icon(
                                              Icons.logout,
                                              size: 16,
                                              color: AppTheme.primaryRed
                                            ),
                                          ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Welcome message
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              String welcomeText = 'WELCOME';
                              if (state is AuthAuthenticated && state.user.displayName != null && state.user.displayName!.isNotEmpty) {
                                welcomeText = 'WELCOME ${state.user.displayName!.toUpperCase()}!';
                              }
                              
                              return Text(
                                welcomeText,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.05,
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Search bar with cyberpunk styling
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.backgroundCard, width: 2),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.jetBrainsMono(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'query.memories...',
                                hintStyle: GoogleFonts.jetBrainsMono(
                                  color: AppTheme.textDisabled,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppTheme.textMuted,
                                  size: 20,
                                ),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    '◉',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppTheme.textMuted,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (query) {
                                context.read<NotesBloc>().add(NotesSearchRequested(query));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Notes list
                Expanded(
                  child: BlocConsumer<NotesBloc, NotesState>(
                    listener: (context, state) {
                      if (state is NotesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.message,
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppTheme.primaryRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      }
                      
                      // Show undo snackbar for deleted notes
                      if (state is NotesLoaded && state.recentlyDeletedNote != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '"${state.recentlyDeletedNote!.title}" → VOID',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                CustomButton(
                                  text: 'RESTORE',
                                  onPressed: () {
                                    context.read<NotesBloc>().add(NotesUndoDeleteRequested(state.recentlyDeletedNote!));
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  },
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
                            ),
                            margin: const EdgeInsets.all(24),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is NotesLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'LOADING NEURAL DATA...',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textTertiary,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (state is NotesLoaded) {
                        return NotesListWidget(
                          notes: state.filteredNotes,
                          onNoteDeleted: (note) {
                            context.read<NotesBloc>().add(NotesNoteDeleted(note));
                          },
                        );
                      }
                      
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 80,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NO NEURAL PATTERNS FOUND',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first memory or try a different search term',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: AppTheme.textDisabled,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Floating Action Button with cyberpunk styling
            Positioned(
              bottom: 32,
              right: 24,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NoteEditorPage(),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Text(
                    '◉',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      ..color = AppTheme.primaryPurple.withOpacity(0.3)
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