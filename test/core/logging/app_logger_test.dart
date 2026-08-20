import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/core/logging/app_logger.dart';
import 'package:obmind/core/logging/log_level.dart';

class _MemoryLogSink implements LogSink {
  final records = <({LogLevel level, String message, Object? error})>[];

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    records.add((level: level, message: message, error: error));
  }
}

void main() {
  test('production logger suppresses debug and keeps info and above', () {
    final sink = _MemoryLogSink();
    final logger = createAppLogger(suppressDebug: true, sink: sink);

    logger.debug('debug-only');
    logger.info('info-ok');
    logger.warning('warning-ok');
    logger.error('error-ok', error: StateError('failed'));

    expect(sink.records.map((record) => record.message), [
      'info-ok',
      'warning-ok',
      'error-ok',
    ]);
    expect(sink.records.map((record) => record.level), [
      LogLevel.info,
      LogLevel.warning,
      LogLevel.error,
    ]);
    expect(sink.records.last.error, isA<StateError>());
  });

  test('debug logger records debug messages', () {
    final sink = _MemoryLogSink();
    final logger = createAppLogger(suppressDebug: false, sink: sink);

    logger.debug('visible');

    expect(sink.records, hasLength(1));
    expect(sink.records.single.level, LogLevel.debug);
    expect(sink.records.single.message, 'visible');
  });

  test('configureAppLogging is the production suppression entry', () {
    final previous = appLogger;
    addTearDown(() {
      appLogger = previous;
    });
    final sink = _MemoryLogSink();

    configureAppLogging(suppressDebug: true, sink: sink);
    appLogger.debug('hidden');
    appLogger.info('shown');

    expect(sink.records.map((record) => record.message), ['shown']);
  });
}
