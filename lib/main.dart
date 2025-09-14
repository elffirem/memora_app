import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memora_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:memora_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:memora_app/features/notes/presentation/bloc/notes_event.dart';

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

  try {
    await Firebase.initializeApp();
  } catch (e) {
  }

  await Hive.initFlutter();
  await Hive.openBox('notes');
  await Hive.openBox('user_prefs');

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
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          Future.delayed(const Duration(milliseconds: 500), () {
            context.read<NotesBloc>().add(NotesLoadRequested());
          });
          return const NotesHomePage();
        }
        return const AuthPage();
      },
    );
  }
}
