import 'dart:io';
import 'package:ansicolor/ansicolor.dart';

int numberOfAllTasks = 14;

class Log {
  static AnsiPen _red = AnsiPen()..red(bold: true);
  static AnsiPen _yellow = AnsiPen()..yellow(bold: true);
  static AnsiPen _green = AnsiPen()..green(bold: true);
  static AnsiPen _blue = AnsiPen()..blue(bold: true);
  static AnsiPen _gray05 = AnsiPen()..gray(level: 0.5);
  static AnsiPen _gray09 = AnsiPen()..gray(level: 0.9);
  static int _numberOfTasksCompleted = 0;
  static int _lastMessageLength = 0;

  /// Information log with `white` color
  static void info(String message) => _write(message, withColor: _gray09);

  /// Error log with `red` color
  static void error(String message) {
    stdout.writeln();
    _write(message, withColor: _red);
  }

  /// Write `error` log and exit the program
  static void errorAndExit(String message) {
    error(message);
    exit(-1);
  }

  /// Warning log with `yellow` color
  static void warn(String message) => _write(message, withColor: _yellow);

  /// Success log with `green` color
  static void success(String message) => _write(message, withColor: _green);

  /// Link log with `blue` color
  static void link(String message) => _write(message, withColor: _blue);

  static void _write(String message, {required AnsiPen withColor}) {
    stdout.writeln(withColor(message));
  }

  static void _renderProgressBar() {
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
        percentage == 100 ? _green(' $percentage%') : _yellow(' $percentage%'));
  }

  /// Info log on a new task
  static void startingTask(String name) {
    final emptyStr = _getlastMessageEmptyStringLength();
    _lastMessageLength = name.length;
    _renderProgressBar();
    stdout.write(_yellow(' $name..$emptyStr'));
  }

  /// Info log on a completed task
  static void taskCompleted(String name) {
    _numberOfTasksCompleted++;
    stdout.writeCharCode(13);
    stdout.write(_green('✓ '));
    stdout.writeln(
        '$name                                                           ');
    if (_numberOfTasksCompleted >= numberOfAllTasks) {
      final emptyStr = _getlastMessageEmptyStringLength();
      _renderProgressBar();
      stdout.writeln(emptyStr);
    }
  }

  static String _getlastMessageEmptyStringLength() {
    var emptyStr = '';
    for (var i = 0; i < _lastMessageLength + 8; i++) {
      emptyStr += ' ';
    }
    return emptyStr;
  }
}
