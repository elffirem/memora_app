import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isSecondary;
  final bool isGradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double borderRadius;
  final double? letterSpacing;
  final String? fontFamily;
  final Widget? child;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isGradient = true,
    this.width,
    this.height = 56,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w800,
    this.textColor,
    this.backgroundColor,
    this.gradientColors,
    this.borderRadius = 16,
    this.letterSpacing = 0.02,
    this.fontFamily = 'JetBrains Mono',
    this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled && !isLoading ? onPressed : null;
    
    if (isGradient && !isSecondary) {
      return _buildGradientButton(effectiveOnPressed);
    } else {
      return _buildStandardButton(effectiveOnPressed);
    }
  }

  Widget _buildGradientButton(VoidCallback? effectiveOnPressed) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? [
            AppTheme.primaryPurple,
            AppTheme.primaryRed,
            AppTheme.primaryCyan,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardButton(VoidCallback? effectiveOnPressed) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isSecondary 
            ? Colors.black.withOpacity(0.6) 
            : AppTheme.primaryPurple),
        borderRadius: BorderRadius.circular(borderRadius),
        border: isSecondary 
            ? Border.all(color: AppTheme.backgroundCard, width: 2)
            : null,
        boxShadow: isSecondary ? null : [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isSecondary ? AppTheme.textTertiary : Colors.black,
            ),
          ),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    return Center(
      child: Text(
        text,
        style: _getTextStyle(),
        textAlign: TextAlign.center,
      ),
    );
  }

  TextStyle _getTextStyle() {
    if (fontFamily == 'JetBrains Mono') {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor ?? (isSecondary ? AppTheme.textTertiary : Colors.black),
        letterSpacing: letterSpacing,
      );
    } else {
      return GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor ?? (isSecondary ? AppTheme.textTertiary : Colors.black),
        letterSpacing: letterSpacing,
      );
    }
  }
}

// Specialized cyberpunk button for save actions
class CyberpunkSaveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const CyberpunkSaveButton({
    super.key,
    this.text = 'ENCODE',
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isGradient: true,
      gradientColors: [AppTheme.primaryPurple, AppTheme.primaryRed],
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.02,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      enabled: enabled,
    );
  }
}

// Specialized cyberpunk button for secondary actions
class CyberpunkSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CyberpunkSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isPrimary: false,
      isSecondary: true,
      isGradient: false,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textColor: AppTheme.textMuted,
      enabled: enabled,
    );
  }
}
