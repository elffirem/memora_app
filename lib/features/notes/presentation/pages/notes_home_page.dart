import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memora_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:memora_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_event.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_state.dart';

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
  String? _lastDeletedNoteId; // Track last deleted note to prevent duplicate snackbars
  bool _isSnackBarShowing = false; // Prevent multiple snackbars

  @override
  void initState() {
    super.initState();
    _viewModel = NotesHomeViewModel(context: context);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _viewModel.loadNotes();
    });
    
    context.read<ConnectivityService>().stream.listen((isConnected) {
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addBulkTestNotes(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    final notes = [
      {"title": "Team Meeting", "content": "Discuss project roadmap and assign new tasks for next sprint."},
      {"title": "Grocery List", "content": "Buy milk, eggs, bread, and fresh vegetables from the store."},
      {"title": "Dentist Appointment", "content": "Scheduled for Monday at 2PM, remember to bring insurance card."},
      {"title": "Workout Plan", "content": "Focus on cardio and abs today, 45 minutes at the gym."},
      {"title": "Exam Reminder", "content": "Study chapters 4–6 from the physics textbook."},
      {"title": "Birthday Gift", "content": "Buy headphones for Sarah's birthday party this weekend."},
      {"title": "Daily Reflection", "content": "Today I felt productive and managed to complete most tasks."},
      {"title": "Shopping Ideas", "content": "New shoes, backpack, and a smartwatch for next month."},
      {"title": "Client Call", "content": "Call John at 3PM to review the contract details."},
      {"title": "Dinner Recipe", "content": "Try making pasta with homemade tomato sauce."},
      {"title": "Budget Notes", "content": "Cut down on dining out to save for vacation."},
      {"title": "Startup Idea", "content": "AI-based note-taking app with auto summaries."},
      {"title": "Conference Agenda", "content": "Attend keynote at 10AM and networking at 2PM."},
      {"title": "Laundry Reminder", "content": "Wash clothes before Friday trip."},
      {"title": "Weekend Trip", "content": "Pack essentials for camping at the lake."},
      {"title": "Book to Read", "content": "Start reading \"Atomic Habits\" this week."},
      {"title": "Code Fixes", "content": "Debug login form and add validation for password reset."},
      {"title": "App Design", "content": "Sketch wireframes for the new dashboard."},
      {"title": "Meeting Notes", "content": "Marketing wants more visuals in the product pitch."},
      {"title": "Travel Bucket List", "content": "Japan, Iceland, and New Zealand in next 5 years."},
      {"title": "Doctor Visit", "content": "Annual check-up scheduled next Wednesday morning."},
      {"title": "Daily Gratitude", "content": "Grateful for sunny weather and a productive morning."},
      {"title": "Job Application", "content": "Update resume and cover letter for Google internship."},
      {"title": "Team Retrospective", "content": "What went well: communication. Needs improvement: testing."},
      {"title": "Music Playlist", "content": "Add new tracks from Coldplay and Imagine Dragons."},
      {"title": "Study Group", "content": "Meet with Anna and Mike to review calculus exercises."},
      {"title": "Groceries", "content": "Bananas, yogurt, cereal, chicken, olive oil."},
      {"title": "Fitness Goal", "content": "Run 5 kilometers without breaks by end of month."},
      {"title": "Daily Journal", "content": "Felt stressed but meditation helped in the evening."},
      {"title": "Car Maintenance", "content": "Change oil and check tire pressure this weekend."},
      {"title": "Presentation Notes", "content": "Highlight revenue growth and user adoption."},
      {"title": "Startup Funding", "content": "Research angel investors and prepare pitch deck."},
      {"title": "House Tasks", "content": "Fix leaky faucet, vacuum living room, organize books."},
      {"title": "Shopping Reminder", "content": "Order laptop stand and wireless mouse online."},
      {"title": "Daily Learning", "content": "Watched a tutorial about Flutter state management."},
      {"title": "Event Plan", "content": "Reserve venue for graduation party."},
      {"title": "Gift Ideas", "content": "Buy candles and chocolates for Mother's Day."},
      {"title": "Call Reminder", "content": "Ring grandma Sunday evening."},
      {"title": "Daily Reflection", "content": "Learned to stay calm during a busy workday."},
      {"title": "App Bug", "content": "Fix crashing issue when user logs out."},
      {"title": "Business Idea", "content": "Coffee subscription service for offices."},
      {"title": "Cooking Note", "content": "Bake banana bread with walnuts."},
      {"title": "Weekend Plan", "content": "Go hiking on Saturday, brunch on Sunday."},
      {"title": "Exam Schedule", "content": "Math exam Tuesday 9AM, English Thursday 11AM."},
      {"title": "Meditation Log", "content": "10 minutes mindfulness before bed."},
      {"title": "Shopping List", "content": "Soap, shampoo, toothpaste, conditioner."},
      {"title": "Work Reminder", "content": "Send weekly report to manager by 5PM."},
      {"title": "Goals for Month", "content": "Exercise 3 times weekly, read 2 books, save \$200."},
      {"title": "Learning Note", "content": "Read article about AI ethics and implications."},
      {"title": "Final Reflection", "content": "This week was challenging but I improved my focus."},
      {"title": "Conference Notes – Keynote Speech", "content": "The speaker discussed the future of AI and its role in everyday productivity tools. Key points included natural language processing, personalized assistants, and responsible AI ethics. He also highlighted the importance of human creativity alongside automation. The talk concluded with predictions about AI in education, healthcare, and small businesses."},
      {"title": "Reflection on Personal Growth", "content": "Over the past month, I noticed a change in how I handle stressful situations. Instead of panicking, I've started breaking problems into smaller tasks and addressing them one by one. This shift has helped me feel more in control and less anxious, even when deadlines are tight. Meditation and journaling have been key habits in this transformation."},
      {"title": "Book Summary – Atomic Habits", "content": "The book emphasizes that small habits compound into remarkable results over time. The author introduces the \"four laws of behavior change\": make it obvious, make it attractive, make it easy, and make it satisfying. I especially liked the part about habit stacking, where you attach a new habit to an existing one, making it easier to stick."},
      {"title": "Long To-Do List", "content": "Finish preparing slides for Monday's presentation. Send updated project timeline to the team. Call the bank regarding the new account. Grocery shopping: rice, chicken, fruits, snacks. Laundry before the weekend trip. Buy Sarah's birthday gift (headphones). Read at least 20 pages of my current book. Meditate for 10 minutes before bed."},
    ];

    context.read<NotesBloc>().add(NotesBulkCreateRequested(notes: notes));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Adding ${notes.length} notes to backend...',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
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
            style: const TextStyle(
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
            Positioned.fill(
              child: CustomPaint(
                painter: ConstellationPainter(),
              ),
            ),
            Column(
              children: [
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                              ).createShader(bounds),
                                child: Text(
                                  'MEMORA',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.03,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _addBulkTestNotes(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppTheme.primaryCyan, AppTheme.primaryPurple],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.backgroundCard, width: 1),
                                      ),
                                      child: Text(
                                        'TEST',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                          letterSpacing: 0.05,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                          style: const TextStyle(
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
                          
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              String welcomeText = 'WELCOME';
                              if (state is AuthAuthenticated && state.user.displayName != null && state.user.displayName!.isNotEmpty) {
                                welcomeText = 'WELCOME ${state.user.displayName!.toUpperCase()}!';
                              }
                              
                              return Text(
                                welcomeText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.05,
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.backgroundCard, width: 2),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'query.memories...',
                                hintStyle: const TextStyle(
                                  color: AppTheme.textDisabled,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppTheme.textMuted,
                                  size: 20,
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          context.read<NotesBloc>().add(NotesSearchRequested(''));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.textMuted.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: AppTheme.textMuted,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        '◉',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (query) {
                                setState(() {}); // Rebuild to show/hide clear button
                                context.read<NotesBloc>().add(NotesSearchRequested(query));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: BlocConsumer<NotesBloc, NotesState>(
                    listener: (context, state) {
                      if (state is NotesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.message,
                              style: const TextStyle(
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
                      
                      if (state is NotesLoaded && 
                          state.recentlyDeletedNote != null && 
                          _lastDeletedNoteId != state.recentlyDeletedNote!.id &&
                          !_isSnackBarShowing) {
                        
                        _lastDeletedNoteId = state.recentlyDeletedNote!.id;
                        _isSnackBarShowing = true;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '"${state.recentlyDeletedNote!.title}" → VOID',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                CustomButton(
                                  text: 'RESTORE',
                                  onPressed: () {
                                    final noteToRestore = state.recentlyDeletedNote!;
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    _lastDeletedNoteId = null;
                                    _isSnackBarShowing = false;
                                    context.read<NotesBloc>().add(NotesUndoDeleteRequested(noteToRestore));
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
                            duration: const Duration(seconds: 4),
                          ),
                        ).closed.then((_) {
                          if (_isSnackBarShowing) {
                            _isSnackBarShowing = false;
                          }
                        });
                      }
                      
                      if (state is NotesLoaded && 
                          state.recentlyDeletedNote == null && 
                          _lastDeletedNoteId != null &&
                          !_isSnackBarShowing) {
                        _lastDeletedNoteId = null;
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
                                style: const TextStyle(
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
                              style: const TextStyle(
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
                    style: const TextStyle(
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

class ConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.3)
      ..style = PaintingStyle.fill;

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