import 'package:flutter/material.dart';

import '../theme/racing_colors.dart';

/// Radial gradient background matching the GarageCrew website
/// Wrap your Scaffold body with this for racing theme effect
class RacingGradientBackground extends StatelessWidget {
  const RacingGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.6), // Top-left-ish like web (20% 20%)
          radius: 1.2,
          colors: [
            RacingColors.backgroundGradientStart, // #1a5bbf
            RacingColors.backgroundGradientMid, // #0b2d75
            RacingColors.backgroundGradientEnd, // #081a3a
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}
