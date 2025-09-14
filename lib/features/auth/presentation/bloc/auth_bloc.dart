import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  AuthRegisterRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    
    // Listen to Firebase auth state changes
    _setupAuthStateListener();
  }

  void _setupAuthStateListener() {
    try {
      _firebaseAuth.authStateChanges().listen((User? user) {
        if (user != null && state is! AuthAuthenticated) {
          add(AuthCheckRequested());
        } else if (user == null && state is! AuthUnauthenticated && state is! AuthInitial && state is! AuthLoading) {
          add(AuthLogoutRequested());
        }
      });
    } catch (e) {
      print('Firebase auth state listener error: $e');
    }
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthCheckRequested - Checking current user...');
    emit(AuthLoading());
    try {
      final user = await loginUseCase.getCurrentUser();
      print('👤 Current user: ${user?.email ?? "null"}');
      if (user != null) {
        print('✅ User authenticated, going to home page');
        emit(AuthAuthenticated(user));
      } else {
        print('❌ No user found, showing auth page');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 Login attempt for: ${event.email}');
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      print('✅ Login successful for: ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (e) {
      print('❌ Login failed: $e');
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(
        event.email,
        event.password,
        event.displayName,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

