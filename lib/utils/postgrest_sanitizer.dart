/// Utility for sanitizing user input before use in PostgREST filter expressions.
///
/// PostgREST filter strings (used in Supabase `.or()`, `.filter()`, etc.)
/// use special characters like `,`, `.`, `(`, `)`, `%` as delimiters.
/// Unsanitized user input can manipulate filter expressions.
class PostgrestSanitizer {
  PostgrestSanitizer._();

  /// Characters that have special meaning in PostgREST filter expressions.
  static final _dangerousChars = RegExp(r'[,\.\(\)\\]');

  /// Sanitizes user input for safe use in PostgREST filter strings.
  ///
  /// Strips characters that could manipulate PostgREST filter expressions:
  /// `,` (separates filter conditions), `.` (separates field.operator.value),
  /// `(` `)` (groups conditions), `\` (escape character).
  ///
  /// Example:
  /// ```dart
  /// final safe = PostgrestSanitizer.sanitize('user,id.eq.admin');
  /// // Returns: 'userideqadmin'
  /// ```
  static String sanitize(String input) {
    return input.replaceAll(_dangerousChars, '');
  }
}
