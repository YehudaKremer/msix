import 'dart:io';
import 'package:cli_util/cli_logging.dart';

import 'configuration.dart';

const runnerRcPath = 'windows/runner/Runner.rc';

/// Handles windows (pre-)build steps.
class WindowsBuild {
  Configuration _config;
  Logger _logger;

  WindowsBuild(this._config, this._logger);

  /// Run "flutter build windows" command
  Future<void> build() async {
    var originalRunnerRcContent = await _getRunnerRcContent();
    _updateRunnerCompanyName();

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

    await _restoreRunnerRcContent(originalRunnerRcContent);
  }

  Future<String> _getRunnerRcContent() async =>
      await File(runnerRcPath).readAsString();

  Future<File> _restoreRunnerRcContent(String content) async {
    _logger.trace('restore Runner.rc content');
    return await File(runnerRcPath).writeAsString(content);
  }

  /// Update the company name 'com.example' in the Runner.rc file
  Future<void> _updateRunnerCompanyName() async {
    _logger
        .trace('updating Runner.rc "CompanyName" to "${_config.identityName}"');

    var runnerRcContentLines = await File(runnerRcPath).readAsLines();
    var updatedRunnerRcContent = '';

    for (var line in runnerRcContentLines) {
      if (line.contains('VALUE "CompanyName"')) {
        line =
            '            VALUE "CompanyName", "${_config.identityName}" "\\0"';
      } else if (line.contains('VALUE "LegalCopyright"')) {
        line =
            '            VALUE "LegalCopyright", "Copyright (C) ${DateTime.now().year} ${_config.identityName}. All rights reserved." "\\0"';
      }

      updatedRunnerRcContent += '$line\n';
    }

    await File(runnerRcPath).writeAsString(updatedRunnerRcContent);
  }
}
