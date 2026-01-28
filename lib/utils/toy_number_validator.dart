import '../l10n/app_localizations.dart';

/// Utility class for validating Hot Wheels Toy Number format
///
/// Toy Numbers follow the format: 3 uppercase letters + 2 digits (e.g., JJJ02, DTX47, K5904)
class ToyNumberValidator {
  ToyNumberValidator._(); // Private constructor to prevent instantiation

  /// Regex pattern for Toy Number format: 3 uppercase letters + 2 digits
  static final _formatRegex = RegExp(r'^[A-Z]{3}[0-9]{2}$');

  /// Validates that the Toy Number is not empty and matches the required format
  ///
  /// Returns null if valid, or an error message if invalid
  static String? validateFormat(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.toyNumberEmpty;
    }
    if (!_formatRegex.hasMatch(value.trim())) {
      return l10n.toyNumberInvalidFormat;
    }
    return null;
  }

  /// Normalizes a Toy Number by trimming whitespace and converting to uppercase
  ///
  /// Example: " abc12 " -> "ABC12"
  static String normalize(String value) {
    return value.trim().toUpperCase();
  }

  /// Checks if a string matches the Toy Number format without localization
  ///
  /// Useful for quick validation without requiring AppLocalizations context
  static bool isValidFormat(String value) {
    return _formatRegex.hasMatch(value.trim());
  }
}
