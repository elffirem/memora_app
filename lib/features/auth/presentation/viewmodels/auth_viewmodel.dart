import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class AuthViewModel {
  final BuildContext context;

  AuthViewModel({required this.context});

  // Handle login
  void login(String email, String password) {
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: email.trim(),
        password: password,
      ),
    );
  }

  // Handle register
  void register(String email, String password) {
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        email: email.trim(),
        password: password,
      ),
    );
  }

  // Handle logout
  void logout() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated;
  }

  // Check if auth is loading
  bool isLoading() {
    final state = context.read<AuthBloc>().state;
    return state is AuthLoading;
  }

  // Get current user
  String? getCurrentUser() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user.email;
    }
    return null;
  }

  // Show error message
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Show success message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Validate email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Get current auth state
  AuthState getCurrentState() {
    return context.read<AuthBloc>().state;
  }
}
