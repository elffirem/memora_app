import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Color? fillColor;
  final bool filled;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final Color? hintColor;
  final double? letterSpacing;
  final double? height;
  final String? fontFamily;
  final bool isCyberpunk;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.textAlignVertical,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.fillColor,
    this.filled = false,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.textColor,
    this.hintColor,
    this.letterSpacing,
    this.height,
    this.fontFamily = 'Space Grotesk',
    this.isCyberpunk = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? _getDefaultStyle();
    final effectiveHintStyle = hintStyle ?? _getDefaultHintStyle();
    final effectiveLabelStyle = labelStyle ?? _getDefaultLabelStyle();

    if (isCyberpunk) {
      return _buildCyberpunkTextField(
        effectiveStyle,
        effectiveHintStyle,
        effectiveLabelStyle,
      );
    } else {
      return _buildStandardTextField(
        effectiveStyle,
        effectiveHintStyle,
        effectiveLabelStyle,
      );
    }
  }

  Widget _buildCyberpunkTextField(
    TextStyle effectiveStyle,
    TextStyle effectiveHintStyle,
    TextStyle effectiveLabelStyle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor ?? Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.backgroundCard,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        textAlignVertical: textAlignVertical,
        style: effectiveStyle,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: effectiveHintStyle,
          labelStyle: effectiveLabelStyle,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: border ?? InputBorder.none,
          enabledBorder: enabledBorder ?? InputBorder.none,
          focusedBorder: focusedBorder ?? InputBorder.none,
          filled: filled,
          fillColor: fillColor,
        ),
      ),
    );
  }

  Widget _buildStandardTextField(
    TextStyle effectiveStyle,
    TextStyle effectiveHintStyle,
    TextStyle effectiveLabelStyle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      textAlignVertical: textAlignVertical,
      style: effectiveStyle,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: effectiveHintStyle,
        labelStyle: effectiveLabelStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        border: border,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        filled: filled,
        fillColor: fillColor,
      ),
    );
  }

  TextStyle _getDefaultStyle() {
    if (fontFamily == 'JetBrains Mono') {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor ?? AppTheme.textPrimary,
        letterSpacing: letterSpacing,
        height: height,
      );
    } else {
      return GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor ?? AppTheme.textPrimary,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  TextStyle _getDefaultHintStyle() {
    if (fontFamily == 'JetBrains Mono') {
      return GoogleFonts.jetBrainsMono(
        color: hintColor ?? AppTheme.textDisabled,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    } else {
      return GoogleFonts.spaceGrotesk(
        color: hintColor ?? AppTheme.textDisabled,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
  }

  TextStyle _getDefaultLabelStyle() {
    if (fontFamily == 'JetBrains Mono') {
      return GoogleFonts.jetBrainsMono(
        color: hintColor ?? AppTheme.textDisabled,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } else {
      return GoogleFonts.spaceGrotesk(
        color: hintColor ?? AppTheme.textDisabled,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    }
  }
}

// Specialized cyberpunk text field for title input
class CyberpunkTitleField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  const CyberpunkTitleField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.backgroundCard,
            width: 2,
          ),
        ),
      ),
      child: CustomTextField(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
        textInputAction: textInputAction,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        textColor: AppTheme.textPrimary,
        hintColor: AppTheme.textDisabled,
        letterSpacing: -0.02,
        fontFamily: 'JetBrains Mono',
        isCyberpunk: false, // We handle the border ourselves
      ),
    );
  }
}

// Specialized cyberpunk text field for content input
class CyberpunkContentField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool expands;

  const CyberpunkContentField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.maxLines,
    this.expands = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      textColor: AppTheme.textSecondary,
      hintColor: AppTheme.textDisabled,
      height: 1.8,
      fontFamily: 'Space Grotesk',
      maxLines: maxLines,
      expands: expands,
      textAlignVertical: TextAlignVertical.top,
      isCyberpunk: false, 
    );
  }
}
