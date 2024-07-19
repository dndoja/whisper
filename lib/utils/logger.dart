import 'package:flutter/foundation.dart' show debugPrint;
import 'package:stack_trace/stack_trace.dart' show Trace;
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

const lineLength = 80;
const leftPadding = 0;
const logToTerminal = false;

final logger = LoggerWrapper(
  Logger(
    output: logToTerminal ? _TerminalOutput() : _DeveloperConsoleOutput(),
    printer: PrettyPrinter(
      colors: false,
      lineLength: lineLength,
      methodCount: 1,
      errorMethodCount: 8,
    ),
  ),
);

class LoggerWrapper {
  const LoggerWrapper(this.logger);
  final Logger logger;

  void t(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) =>
      logger.t(
        message,
        error: error,
        stackTrace: stackTrace ?? Trace([]),
        time: time,
      );

  void d(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) =>
      logger.d(
        message,
        error: error,
        stackTrace: stackTrace ?? Trace([]),
        time: time,
      );

  void i(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) =>
      logger.i(
        message,
        error: error,
        stackTrace: stackTrace ?? Trace([]),
        time: time,
      );

  void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) =>
      logger.w(
        message,
        error: error,
        stackTrace: stackTrace ?? Trace([]),
        time: time,
      );

  void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) =>
      logger.e(
        message,
        error: error,
        stackTrace: stackTrace ?? Trace([]),
        time: time,
      );
}

class _TerminalOutput extends LogOutput {
  final RegExp _splitByChunksPattern = RegExp('.{1,800}');

  @override
  void output(OutputEvent event) => event.lines.forEach(_printByChunks);

  /// We have to split the message into chunks due to a limitation in iOS that
  /// truncates messages after 1024 characters.
  void _printByChunks(String text) => _splitByChunksPattern
      .allMatches(text)
      .forEach((match) => debugPrint(match.group(0).toString()));
}

// ignore: unused_element
class _DeveloperConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(PrettyPrinter.doubleDivider * (lineLength - leftPadding));
    for (final line in event.lines) {
      final words = line.split(' ');

      int charsInLine = 0;

      for (final word in words) {
        if (charsInLine + word.length > lineLength) {
          buffer.writeln();
          charsInLine = 0;
        }

        buffer.write('$word ');
        charsInLine += word.length + 1;
      }
      buffer.writeln();
    }

    developer.log(buffer.toString());
  }
}
