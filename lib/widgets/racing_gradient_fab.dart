import 'package:flutter/material.dart';

import '../theme/racing_colors.dart';

/// FloatingActionButton with racing red→orange gradient
class RacingGradientFAB extends StatelessWidget {
  const RacingGradientFAB({
    super.key,
    required this.onPressed,
    required this.child,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RacingColors.actionGradientStart, // Red
              RacingColors.actionGradientEnd, // Orange
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: RacingColors.red.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
