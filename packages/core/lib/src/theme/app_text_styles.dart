import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

import 'app_colors.dart';

part 'app_text_styles.tailor.dart';

// The design specifies Inter; bundle it under packages/core/assets/fonts and
// set this constant to 'Inter' (plus the pubspec fonts section) to adopt it.
const String? _fontFamily = null;

/// Text style tokens, sizes/weights/line-heights from docs/design/tokens.css.
@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class AppTextStyles extends ThemeExtension<AppTextStyles>
    with _$AppTextStylesTailorMixin {
  const AppTextStyles({
    required this.headline,
    required this.title,
    required this.body,
    required this.bodySecondary,
    required this.label,
    required this.price,
  });

  @override
  final TextStyle headline;
  @override
  final TextStyle title;
  @override
  final TextStyle body;
  @override
  final TextStyle bodySecondary;
  @override
  final TextStyle label;
  @override
  final TextStyle price;

  static AppTextStyles forColors(AppColors colors) => AppTextStyles(
        headline: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        title: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        body: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
        ),
        bodySecondary: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        label: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: colors.textSecondary,
        ),
        price: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: colors.primary,
        ),
      );
}
