import 'package:flutter/foundation.dart';

class ErrorLogger {
  static void log(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      if (context != null) {
        buffer.writeln('[$context]');
      }
      buffer.writeln('Error: $error');
      debugPrint(buffer.toString());
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
