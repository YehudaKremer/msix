import 'dart:io';
import 'package:ansicolor/ansicolor.dart';

int numberOfAllTasks = 16;

/// Handles simple logs, visual logs, colored, and errors logs
class Log {
  AnsiPen ansiPen = AnsiPen();
  AnsiPen _red = AnsiPen()..red(bold: true);
  AnsiPen _yellow = AnsiPen()..yellow(bold: true);
  AnsiPen _green = AnsiPen()..green(bold: true);
  AnsiPen _blue = AnsiPen()..blue(bold: true);
  AnsiPen _gray05 = AnsiPen()..gray(level: 0.5);
  AnsiPen _gray09 = AnsiPen()..gray(level: 0.9);
  int _numberOfTasksCompleted = 0;
  int _lastMessageLength = 0;

  /// Information log with `white` color
  void info(String message) => _write(message, withColor: _gray09);

  /// Warning log with `yellow` color
  void warn(String message) => _write(message, withColor: _yellow);

  /// Success log with `green` color
  void success(String message) => _write(message, withColor: _green);

  /// Link log with `blue` color
  void link(String message) => _write(message, withColor: _blue);

  /// Error log with `red` color
  void error(String message) {
    stdout.writeln();
    _write(message, withColor: _red);
  }

  void _write(String message, {required AnsiPen withColor}) {
    stdout.writeln(withColor(message));
  }

  void _renderProgressBar() {
    stdout.writeCharCode(13);

    var blueBars = '';
    for (var z = _numberOfTasksCompleted; z > 0; z--) {
      blueBars += '❚❚';
    }
    stdout.write(_blue(blueBars));
    var grayBars = '';
    for (var z = numberOfAllTasks - _numberOfTasksCompleted; z > 0; z--) {
      grayBars += '❚❚';
    }
    stdout.write(_gray05(grayBars));

    var percentage = (_numberOfTasksCompleted * 100 / numberOfAllTasks).floor();
    stdout.write(
        percentage == 100 ? _green(' $percentage%') : _gray09(' $percentage%'));
  }

  /// Info log on a new task
  void startingTask(String name) {
    final emptyStr = _getLastMessageEmptyStringLength();
    _lastMessageLength = name.length;
    _renderProgressBar();
    stdout.write(_gray09(' $name..$emptyStr'));
  }

  /// Info log on a completed task
  void taskCompleted(String name) {
    _numberOfTasksCompleted++;
    stdout.writeCharCode(13);
    stdout.write(_green('✓ '));
    stdout.writeln(
        '$name                                                           ');
    if (_numberOfTasksCompleted >= numberOfAllTasks) {
      final emptyStr = _getLastMessageEmptyStringLength();
      _renderProgressBar();
      stdout.writeln(emptyStr);
    }
  }

  String _getLastMessageEmptyStringLength() {
    var emptyStr = '';
    for (var i = 0; i < _lastMessageLength + 8; i++) {
      emptyStr += ' ';
    }
    return emptyStr;
  }
}

class GeneralException implements Exception {
  String message;
  GeneralException(this.message);
}
