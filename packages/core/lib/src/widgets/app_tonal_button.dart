import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tonal button from the design: surfaceAlt background, primary text.
class AppTonalButton extends StatelessWidget {
  const AppTonalButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.surfaceAlt,
        foregroundColor: colors.primary,
        textStyle:
            context.appTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m - AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
