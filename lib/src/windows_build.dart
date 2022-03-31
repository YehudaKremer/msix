import 'dart:io';
import 'package:cli_util/cli_logging.dart' show Logger;

import 'configuration.dart';

const runnerRcPath = 'windows/runner/Runner.rc';
const mainCppPath = 'windows/runner/main.cpp';

/// Handles windows files build steps
class WindowsBuild {
  final Configuration _config;
  final Logger _logger;

  WindowsBuild(this._config, this._logger);

  /// Run "flutter build windows" command
  Future<void> build() async {
    //var originalRunnerRcContent = await _getRunnerRcContent();
    //await _updateRunnerCompanyName();
    //await _updateWindowTitle();

    var buildWindowsArguments = ['build', 'windows'];
    if (_config.createWithDebugBuildFiles) buildWindowsArguments.add('--debug');

    var loggerProgress = _logger
        .progress('running "flutter ${buildWindowsArguments.join(' ')}"');

    var windowsBuildProcess =
        await Process.run('flutter', buildWindowsArguments, runInShell: true);

    if (windowsBuildProcess.exitCode != 0) {
      _logger.stderr(windowsBuildProcess.stdout);
      throw windowsBuildProcess.stderr;
    }

    loggerProgress.finish(showTiming: true);

    //await _restoreRunnerRcContent(originalRunnerRcContent);
  }

  // Future<String> _getRunnerRcContent() async =>
  //     await File(runnerRcPath).readAsString();

  // Future<File> _restoreRunnerRcContent(String content) async {
  //   _logger.trace('restore Runner.rc content');
  //   return await File(runnerRcPath).writeAsString(content);
  // }

  /// Update the company name 'com.example' in the Runner.rc file
  /// with the [_config.identityName] value.
  // Future<void> _updateRunnerCompanyName() async {
  //   _logger
  //       .trace('updating Runner.rc "CompanyName" to "${_config.identityName}"');

  //   var runnerRcContentLines = await File(runnerRcPath).readAsLines();
  //   var updatedRunnerRcContent = '';

  //   for (var line in runnerRcContentLines) {
  //     if (line.contains('VALUE "CompanyName"')) {
  //       line =
  //           '            VALUE "CompanyName", "${_config.identityName}" "\\0"';
  //     } else if (line.contains('VALUE "LegalCopyright"')) {
  //       line =
  //           '            VALUE "LegalCopyright", "Copyright (C) ${DateTime.now().year} ${_config.identityName}. All rights reserved." "\\0"';
  //     }

  //     updatedRunnerRcContent += '$line\n';
  //   }

  //   await File(runnerRcPath).writeAsString(updatedRunnerRcContent);
  // }

  /// Update the app window title in the main.cpp file
  /// with the [_config.displayName] value.
  // Future<void> _updateWindowTitle() async {
  //   _logger.trace('updating main.cpp window title to "${_config.displayName}"');

  //   var mainCppContentLines = await File(mainCppPath).readAsLines();
  //   var updatedMainCppContent = '';

  //   for (var line in mainCppContentLines) {
  //     if (line.contains('window.CreateAndShow')) {
  //       line =
  //           'if (!window.CreateAndShow(L"${_config.displayName}", origin, size)) {';
  //     }

  //     updatedMainCppContent += '$line\n';
  //   }

  //   await File(mainCppPath).writeAsString(updatedMainCppContent);
  // }
}
