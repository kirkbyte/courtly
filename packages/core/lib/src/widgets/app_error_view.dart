import 'package:flutter/material.dart';

import '../l10n_ext.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_tonal_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.danger, width: 2),
              ),
              child: Text(
                '!',
                style: context.appTextStyles.title
                    .copyWith(color: colors.danger),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              context.l10n.errorTitle,
              style: context.appTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTonalButton(
              onPressed: onRetry,
              child: Text(context.l10n.errorRetry),
            ),
          ],
        ),
      ),
    );
  }
}
