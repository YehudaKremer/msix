import 'dart:io';
import 'package:cli_util/cli_logging.dart';

import 'configuration.dart';
import 'package:msix/src/extensions.dart';

const runnerRcPath = 'windows/runner/Runner.rc';

/// Handles windows (pre-)build steps.
class WindowsBuild {
  Configuration _config;
  Logger _logger;

  WindowsBuild(this._config, this._logger);

  /// Run "flutter build windows" command
  Future<void> build() async {
    var buildWindowsArguments = ['build', 'windows'];
    if (_config.createWithDebugBuildFiles) buildWindowsArguments.add('--debug');

    var loggerProgress = _logger.progress(
        'running "flutter ${buildWindowsArguments.join(' ')}" command');

    var result =
        await Process.run('flutter', buildWindowsArguments, runInShell: true);

    if (result.exitCode != 0) {
      throw result.stdout;
    }

    loggerProgress.finish(showTiming: true);
  }

  /// Update the company name 'com.example' in the Runner.rc file
  Future<void> updateRunnerCompanyName() async {
    if (!_config.updateCompanyName ||
        _config.identityName.isNull ||
        await File(runnerRcPath).exists() == false) return;

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
