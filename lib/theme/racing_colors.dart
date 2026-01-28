import 'package:flutter/material.dart';

/// Racing theme colors matching the GarageCrew website
/// Based on CSS variables from styles.css
abstract class RacingColors {
  // Brand colors (matching web)
  static const red = Color(0xFFE21A23); // --red: #e21a23
  static const orange = Color(0xFFFF6B00); // --orange: #ff6b00
  static const yellow = Color(0xFFFFCC33); // --yellow: #ffcc33
  static const blue = Color(0xFF0B2D75); // --blue: #0b2d75
  static const deepBlue = Color(0xFF081A3A); // --deep-blue: #081a3a
  static const white = Color(0xFFF7F7F7); // --white: #f7f7f7
  static const black = Color(0xFF0F0F0F); // --black: #0f0f0f

  // Gradient colors for background (radial gradient from web)
  static const backgroundGradientStart = Color(0xFF1A5BBF); // Lighter blue
  static const backgroundGradientMid = Color(0xFF0B2D75); // --blue
  static const backgroundGradientEnd = Color(0xFF081A3A); // --deep-blue

  // Action button gradient (CTA from web)
  static const actionGradientStart = Color(0xFFE21A23); // Red
  static const actionGradientEnd = Color(0xFFFF6B00); // Orange

  // Surface colors
  static const surface = Color(0xFF0B2D75); // Card backgrounds
  static const surfaceVariant = Color(0xFF1A3A6B); // Lighter variant

  // Text colors
  static const textPrimary = Color(0xFFF7F7F7); // White text
  static const textSecondary = Color(0xFFCBD5E1); // Muted white
  static const textTertiary = Color(0xFF94A3B8); // Even more muted

  // Status colors
  static const error = Color(0xFFE21A23); // Use racing red for errors
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFFFCC33); // Use racing yellow
}
