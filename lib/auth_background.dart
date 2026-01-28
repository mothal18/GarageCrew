import 'dart:math';

import 'package:flutter/material.dart';

import 'theme/app_colors.dart';

class AnimatedAuthBackground extends StatefulWidget {
  const AnimatedAuthBackground({super.key});

  @override
  State<AnimatedAuthBackground> createState() => _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // Theme-aware colors
        final gradientColors = isDark
            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
            : [const Color(0xFFFAF6F0), const Color(0xFFF5EDE4)];

        final shelfColor = isDark
            ? const Color(0xFF2D2D44)
            : const Color(0xFFD4C4B0);

        final shelfHighlight = isDark
            ? const Color(0xFF3D3D5C)
            : const Color(0xFFE8DED0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return SizedBox.expand(
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Shelves with cars
                  CustomPaint(
                    size: Size(width, height),
                    painter: _ShelfPainter(
                      shelfColor: shelfColor,
                      shelfHighlight: shelfHighlight,
                      isDark: isDark,
                      animationValue: t,
                    ),
                  ),
                  // Subtle overlay for depth
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          (isDark ? Colors.black : Colors.black).withValues(
                            alpha: isDark ? 0.3 : 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ShelfPainter extends CustomPainter {
  _ShelfPainter({
    required this.shelfColor,
    required this.shelfHighlight,
    required this.isDark,
    required this.animationValue,
  });

  final Color shelfColor;
  final Color shelfHighlight;
  final bool isDark;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final shelfPaint = Paint()
      ..color = shelfColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = shelfHighlight
      ..style = PaintingStyle.fill;

    final shelfHeight = 8.0;
    final shelfSpacing = size.height / 5;

    // Car colors
    final carColors = isDark
        ? [
            AppColors.primary.withValues(alpha: 0.6),
            AppColors.secondary.withValues(alpha: 0.5),
            const Color(0xFF6B7280).withValues(alpha: 0.5),
            const Color(0xFFEC4899).withValues(alpha: 0.4),
            const Color(0xFF10B981).withValues(alpha: 0.4),
          ]
        : [
            AppColors.primary.withValues(alpha: 0.35),
            AppColors.secondary.withValues(alpha: 0.3),
            const Color(0xFF4B5563).withValues(alpha: 0.25),
            const Color(0xFFDB2777).withValues(alpha: 0.25),
            const Color(0xFF059669).withValues(alpha: 0.25),
          ];

    final random = Random(42);

    // Draw 4 shelves
    for (int shelfIndex = 0; shelfIndex < 4; shelfIndex++) {
      final y = shelfSpacing * (shelfIndex + 1);

      // Draw shelf
      final shelfRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, y, size.width, shelfHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(shelfRect, shelfPaint);

      // Shelf highlight (top edge)
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), highlightPaint);

      // Draw cars on this shelf
      final carsPerShelf = 5 + (shelfIndex % 2);
      final carWidth = size.width / (carsPerShelf + 1);

      for (int carIndex = 0; carIndex < carsPerShelf; carIndex++) {
        final baseX = carWidth * (carIndex + 0.5);
        final carType = (shelfIndex + carIndex) % 4;
        final color = carColors[(shelfIndex + carIndex) % carColors.length];

        // Subtle animation offset
        final wobble =
            sin(animationValue * 2 * pi + shelfIndex * 0.5 + carIndex * 0.3) *
            2;
        final x = baseX + wobble;
        final carY = y - 2;

        _drawCar(canvas, x, carY, carType, color, random);
      }
    }
  }

  void _drawCar(
    Canvas canvas,
    double x,
    double y,
    int carType,
    Color color,
    Random random,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = 0.8 + random.nextDouble() * 0.4;
    final carWidth = 28.0 * scale;
    final carHeight = 14.0 * scale;

    canvas.save();
    canvas.translate(x, y);

    final path = Path();

    switch (carType) {
      case 0: // Sedan
        _drawSedan(path, carWidth, carHeight);
        break;
      case 1: // Sports car
        _drawSportsCar(path, carWidth, carHeight);
        break;
      case 2: // Truck/SUV
        _drawTruck(path, carWidth, carHeight);
        break;
      case 3: // Muscle car
        _drawMuscleCar(path, carWidth, carHeight);
        break;
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawSedan(Path path, double w, double h) {
    // Body
    path.moveTo(-w / 2, 0);
    path.lineTo(-w / 2, -h * 0.4);
    path.lineTo(-w * 0.35, -h * 0.4);
    path.lineTo(-w * 0.25, -h * 0.85);
    path.lineTo(w * 0.2, -h * 0.85);
    path.lineTo(w * 0.35, -h * 0.4);
    path.lineTo(w / 2, -h * 0.4);
    path.lineTo(w / 2, 0);
    path.close();

    // Front wheel
    path.addOval(
      Rect.fromCircle(center: Offset(-w * 0.3, 0), radius: h * 0.25),
    );
    // Rear wheel
    path.addOval(Rect.fromCircle(center: Offset(w * 0.3, 0), radius: h * 0.25));
  }

  void _drawSportsCar(Path path, double w, double h) {
    // Low sleek body
    path.moveTo(-w / 2, 0);
    path.lineTo(-w / 2, -h * 0.3);
    path.lineTo(-w * 0.2, -h * 0.3);
    path.lineTo(-w * 0.1, -h * 0.65);
    path.lineTo(w * 0.25, -h * 0.65);
    path.lineTo(w * 0.4, -h * 0.3);
    path.lineTo(w / 2, -h * 0.3);
    path.lineTo(w / 2, 0);
    path.close();

    // Wheels
    path.addOval(
      Rect.fromCircle(center: Offset(-w * 0.32, 0), radius: h * 0.22),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.32, 0), radius: h * 0.22),
    );
  }

  void _drawTruck(Path path, double w, double h) {
    // Tall boxy body
    path.moveTo(-w / 2, 0);
    path.lineTo(-w / 2, -h * 0.5);
    path.lineTo(-w * 0.1, -h * 0.5);
    path.lineTo(-w * 0.1, -h);
    path.lineTo(w * 0.35, -h);
    path.lineTo(w * 0.35, -h * 0.5);
    path.lineTo(w / 2, -h * 0.5);
    path.lineTo(w / 2, 0);
    path.close();

    // Wheels
    path.addOval(
      Rect.fromCircle(center: Offset(-w * 0.28, 0), radius: h * 0.28),
    );
    path.addOval(
      Rect.fromCircle(center: Offset(w * 0.32, 0), radius: h * 0.28),
    );
  }

  void _drawMuscleCar(Path path, double w, double h) {
    // Aggressive body with hood scoop
    path.moveTo(-w / 2, 0);
    path.lineTo(-w / 2, -h * 0.35);
    path.lineTo(-w * 0.3, -h * 0.35);
    path.lineTo(-w * 0.2, -h * 0.75);
    path.lineTo(-w * 0.1, -h * 0.85);
    path.lineTo(w * 0.15, -h * 0.85);
    path.lineTo(w * 0.25, -h * 0.75);
    path.lineTo(w * 0.35, -h * 0.35);
    path.lineTo(w / 2, -h * 0.35);
    path.lineTo(w / 2, 0);
    path.close();

    // Bigger wheels
    path.addOval(
      Rect.fromCircle(center: Offset(-w * 0.3, 0), radius: h * 0.28),
    );
    path.addOval(Rect.fromCircle(center: Offset(w * 0.3, 0), radius: h * 0.28));
  }

  @override
  bool shouldRepaint(covariant _ShelfPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
