import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand colors
  static const primary = Color(0xFFFF6A00);
  static const secondary = Color(0xFF0056D2);

  // Text colors - Light
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF64748B);

  // Text colors - Dark
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFFCBD5E1);
  static const textTertiaryDark = Color(0xFF94A3B8);

  // Surface colors - Light
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF1F5F9);
  static const backgroundLight = Color(0xFFF8FAFC);

  // Surface colors - Dark
  static const surfaceDark = Color(0xFF1E293B);
  static const surfaceVariantDark = Color(0xFF334155);
  static const backgroundDark = Color(0xFF0F172A);

  // Status colors
  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFB42318);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);

  // Gradient backgrounds
  static const gradientLightStart = Color(0xFFF7F2EE);
  static const gradientLightEnd = Color(0xFFE3ECF5);
  static const gradientDarkStart = Color(0xFF1E293B);
  static const gradientDarkEnd = Color(0xFF0F172A);
}

abstract class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const full = 999.0;
}

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

abstract class AppShadows {
  static List<BoxShadow> get cardLight => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedLight => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get elevatedDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
