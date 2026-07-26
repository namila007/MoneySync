import 'package:logging/logging.dart';

extension LogLevelX on Logger {
  void debug(Object message, [Object? error, StackTrace? stack]) {
    if (isLoggable(Level.FINE)) {
      log(Level.FINE, message, error, stack);
    }
  }

  void info(Object message) {
    if (isLoggable(Level.INFO)) {
      log(Level.INFO, message);
    }
  }

  void error(Object message, [Object? error, StackTrace? stack]) {
    if (isLoggable(Level.SEVERE)) {
      log(Level.SEVERE, message, error, stack);
    }
  }
}
