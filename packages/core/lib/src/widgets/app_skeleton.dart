import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Pulsing skeleton list used as the loading state of every list screen.
class AppListSkeleton extends StatefulWidget {
  const AppListSkeleton({super.key, this.itemCount = 6, this.itemHeight = 96});

  final int itemCount;
  final double itemHeight;

  @override
  State<AppListSkeleton> createState() => _AppListSkeletonState();
}

class _AppListSkeletonState extends State<AppListSkeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: widget.itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
        itemBuilder: (_, __) => AppSkeletonTile(height: widget.itemHeight),
      ),
    );
  }
}

class AppSkeletonTile extends StatelessWidget {
  const AppSkeletonTile({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
    );
  }
}
