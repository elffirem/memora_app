import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../../../../core/theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
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
              },
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 40),
                            
                            // App Logo with gradient
                            Center(
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryPurple.withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'M',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // App Title with gradient text
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                              ).createShader(bounds),
                              child: Text(
                                'MEMORA',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.03,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Subtitle
                            Text(
                              'Neural Memory Interface',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.02,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 60),
                            
                            // Tab Bar with cyberpunk styling
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.backgroundCard, width: 2),
                              ),
                              child: TabBar(
                                indicatorSize: TabBarIndicatorSize.tab,
                                controller: _tabController,
                                indicator: BoxDecoration(

                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppTheme.primaryPurple, AppTheme.primaryRed, AppTheme.primaryCyan],
                                  ),
                                ),
                                labelColor: Colors.black,
                                unselectedLabelColor: AppTheme.textTertiary,
                                labelStyle: GoogleFonts.jetBrainsMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.02,
                                ),
                                unselectedLabelStyle: GoogleFonts.jetBrainsMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: const [
                                  Tab(text: 'LOGIN'),
                                  Tab(text: 'REGISTER'),
                                ],
                              ), 
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Tab Bar View - Dynamic height
                            IntrinsicHeight(
                              child: SizedBox(
                                height: constraints.maxHeight * 0.6,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: const [
                                    LoginForm(),
                                    RegisterForm(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
      ..color = AppTheme.primaryPurple.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw constellation points
    final points = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.4),
      Offset(size.width * 0.2, size.height * 1.0),
      Offset(size.width * 0.9, size.height * 0.1),
    ];

    for (final point in points) {
      canvas.drawCircle(point, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}