import 'package:flutter/foundation.dart';

/// Severity levels for error logging.
enum ErrorSeverity {
  /// Informational messages for tracking flow.
  info,

  /// Warnings that don't block functionality but may indicate issues.
  warning,

  /// Errors that affect functionality but are recoverable.
  error,

  /// Critical errors that may cause app instability.
  critical,
}

/// Centralized error logging service.
///
/// In debug mode, logs to the console via [debugPrint].
/// In release mode, logs are forwarded to [onError] callback if set.
///
/// To integrate with a crash reporting service (e.g., Sentry, Firebase
/// Crashlytics), set [onError] during app initialization:
///
/// ```dart
/// ErrorLogger.onError = (error, stackTrace, context, severity) {
///   Sentry.captureException(error, stackTrace: stackTrace);
/// };
/// ```
class ErrorLogger {
  /// Optional callback for production error reporting.
  ///
  /// Set this during app initialization to forward errors to a crash
  /// reporting service.
  static void Function(
    Object error,
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity,
  )? onError;

  /// Logs an error with optional stack trace, context, and severity.
  static void log(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    // Always forward to crash reporting if configured
    onError?.call(error, stackTrace, context, severity);

    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.write('[${severity.name.toUpperCase()}]');
      if (context != null) {
        buffer.write(' [$context]');
      }
      buffer.writeln();
      buffer.writeln('Error: $error');
      debugPrint(buffer.toString());
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  /// Logs an informational message.
  static void info(String message, {String? context}) {
    log(message, context: context, severity: ErrorSeverity.info);
  }

  /// Logs a warning.
  static void warning(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    log(error, stackTrace: stackTrace, context: context, severity: ErrorSeverity.warning);
  }

  /// Logs a critical error.
  static void critical(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    log(error, stackTrace: stackTrace, context: context, severity: ErrorSeverity.critical);
  }
}
