import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_colors.tailor.dart';

/// Color tokens. Values come from the Claude Design project and are mirrored
/// in docs/design/tokens.css — raw Color(0xFF…) literals are allowed only
/// here.
@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppColors extends ThemeExtension<AppColors> with _$AppColorsTailorMixin {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.danger,
    required this.outline,
  });

  @override
  final Color background;
  @override
  final Color surface;
  @override
  final Color surfaceAlt;
  @override
  final Color primary;
  @override
  final Color onPrimary;
  @override
  final Color textPrimary;
  @override
  final Color textSecondary;
  @override
  final Color success;
  @override
  final Color danger;
  @override
  final Color outline;

  static const light = AppColors(
    background: Color(0xFFF7F6F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEAF0E9),
    primary: Color(0xFF1B5E3C),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A2420),
    textSecondary: Color(0xFF55665C),
    success: Color(0xFF2E7D53),
    danger: Color(0xFFB23A3A),
    outline: Color(0xFFDCE3DB),
  );

  static const dark = AppColors(
    background: Color(0xFF10140F),
    surface: Color(0xFF171E17),
    surfaceAlt: Color(0xFF1E2A20),
    primary: Color(0xFF55C88A),
    onPrimary: Color(0xFF0C2016),
    textPrimary: Color(0xFFEDF2EC),
    textSecondary: Color(0xFFA6B5AB),
    success: Color(0xFF55C88A),
    danger: Color(0xFFE37B7B),
    outline: Color(0xFF2B362D),
  );
}
