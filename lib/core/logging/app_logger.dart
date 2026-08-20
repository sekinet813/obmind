import 'dart:developer' as developer;

import 'package:obmind/core/logging/log_level.dart';

/// Process-wide logger. Call [configureAppLogging] from `main` before `runApp`.
AppLogger appLogger = createAppLogger(suppressDebug: false);

/// Production entry: drop debug records when [suppressDebug] is true.
void configureAppLogging({required bool suppressDebug, LogSink? sink}) {
  appLogger = createAppLogger(suppressDebug: suppressDebug, sink: sink);
}

/// Creates a logger that can suppress debug output without using `print()`.
AppLogger createAppLogger({required bool suppressDebug, LogSink? sink}) {
  return FilteringLogger(
    minLevel: suppressDebug ? LogLevel.info : LogLevel.debug,
    sink: sink ?? const DeveloperLogSink(),
  );
}

/// Destination for a log record. Domain does not depend on this type.
abstract interface class LogSink {
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Application logging API. Domain must not import this library.
abstract interface class AppLogger {
  void debug(String message, {Object? error, StackTrace? stackTrace});

  void info(String message, {Object? error, StackTrace? stackTrace});

  void warning(String message, {Object? error, StackTrace? stackTrace});

  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Filters records below [minLevel] before writing to [sink].
final class FilteringLogger implements AppLogger {
  const FilteringLogger({required this.minLevel, required this.sink});

  final LogLevel minLevel;
  final LogSink sink;

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) {
      return;
    }
    sink.log(level, message, error: error, stackTrace: stackTrace);
  }
}

/// Writes records through `dart:developer` instead of `print()`.
final class DeveloperLogSink implements LogSink {
  const DeveloperLogSink();

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'obmind',
      level: _developerLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _developerLevel(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    };
  }
}
