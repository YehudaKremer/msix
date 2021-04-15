import 'package:ansicolor/ansicolor.dart';

import 'configuration.dart';

class Log {
  static int _numberOfTasksWeHaveLeft = 12;

  /// Log with colors.
  Log();

  /// Information log with `white` color
  static void info(String message) => _write(message, withColor: AnsiPen()..white(bold: true));

  /// Error log with `red` color
  static void error(String message) => _write(message, withColor: AnsiPen()..red(bold: true));

  /// Warning log with `yellow` color
  static void warn(String message) => _write(message, withColor: AnsiPen()..yellow(bold: true));

  /// Success log with `green` color
  static void success(String message) => _write(message, withColor: AnsiPen()..green(bold: true));

  /// Link log with `blue` color
  static void link(String message) => _write(message, withColor: AnsiPen()..blue(bold: true));

  static void _write(String message, {required AnsiPen withColor}) => print(withColor(message));

  /// Info log on new task
  static void startTask(String name) {
    info('$name.. ');
  }

  /// Success log on completed task
  static void completeTask() {
    _numberOfTasksWeHaveLeft--;
    success('[√]');
  }

  /// Log `Certificate Subject` help information
  static void printCertificateSubjectHelp() {
    Log.warn('Please note: The value of Publisher should be in one line and with commas, example:');
    Log.info(defaultPublisher);
    Log.info('');
    Log.warn('For more information see:');
    Log.link(
        'https://docs.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#determine-the-subject-of-your-packaged-app');
    Log.info('');
  }

  /// Log `Test Certificate` help information
  static void printTestCertificateHelp(String pfxTestPath) {
    Log.info('');
    Log.warn('Certificate Note:');
    Log.warn('every msix installer must be signed with certificate before it can be installed.');
    Log.warn('for testing purposes we signed your msix installer with a TEST certificate,');
    Log.warn('to use this certificate you need to install it, open the certificate file:');
    Log.link(pfxTestPath);
    Log.warn('and follow the instructions at the following link:');
    Log.link('https://www.advancedinstaller.com/install-test-certificate-from-msix.html');
    Log.info('');
  }
}
