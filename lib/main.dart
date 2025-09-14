import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/services/dependency_injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/notes/presentation/pages/notes_home_page.dart';
import 'core/services/connectivity_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('notes');
  await Hive.openBox('user_prefs');

  // Setup dependency injection
  setupDependencyInjection();

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => getIt<NotesBloc>(),
        ),
        BlocProvider(
          create: (context) => ConnectivityService(),
        ),
      ],
      child: MaterialApp(
        title: 'Professional Notes',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('🏠 AuthWrapper state: ${state.runtimeType}');

        if (state is AuthLoading) {
          print('⏳ Showing loading...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          print('🏡 User authenticated, showing home page');
          // Load notes when authenticated
          context.read<NotesBloc>().add(NotesLoadRequested());
          return const NotesHomePage();
        }

        print('🔐 Showing auth page');
        return const AuthPage();
      },
    );
  }
}
