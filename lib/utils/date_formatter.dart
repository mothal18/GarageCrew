/// Utility class for formatting dates consistently across the application
class DateFormatter {
  DateFormatter._(); // Private constructor to prevent instantiation

  /// Formats a DateTime to the format: DD.MM.YYYY HH:MM
  ///
  /// Example: 21.01.2026 19:30
  static String formatDateTime(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.${local.year} $hour:$minute';
  }

  /// Formats a DateTime to the format: DD.MM.YYYY (date only, no time)
  ///
  /// Example: 21.01.2026
  static String formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day.$month.${local.year}';
  }
}
