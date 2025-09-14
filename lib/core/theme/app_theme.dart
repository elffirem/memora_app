import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Avant-garde Color Palette
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color primaryOrange = Color(0xFFF59E0B);
  
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color backgroundSecondary = Color(0xFF111111);
  static const Color backgroundTertiary = Color(0xFF18181B);
  static const Color backgroundCard = Color(0xFF27272A);
  
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFE4E4E7);
  static const Color textTertiary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFF52525B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: primaryCyan,
        tertiary: primaryRed,
        surface: backgroundSecondary,
        background: backgroundDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        displayLarge: GoogleFonts.jetBrainsMono(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: -0.03,
        ),
        displayMedium: GoogleFonts.jetBrainsMono(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.02,
        ),
        displaySmall: GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.02,
        ),
        headlineLarge: GoogleFonts.jetBrainsMono(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.02,
        ),
        headlineMedium: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textTertiary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.05,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: 0.02,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 0.05,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textDisabled,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.02,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.02,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: backgroundCard, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: backgroundCard, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        hintStyle: GoogleFonts.jetBrainsMono(
          color: textDisabled,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.jetBrainsMono(
          color: textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundTertiary.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: backgroundCard, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }

  // Custom gradient decorations
  static BoxDecoration get primaryGradient => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryPurple, primaryRed, primaryCyan],
    ),
    borderRadius: BorderRadius.circular(16),
  );

  static BoxDecoration get cardGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        backgroundTertiary.withOpacity(0.8),
        backgroundCard.withOpacity(0.6),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: backgroundCard, width: 1),
  );

  static BoxDecoration get backgroundGradient => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [backgroundDark, backgroundSecondary, backgroundTertiary],
    ),
  );
}