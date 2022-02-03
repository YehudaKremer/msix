import 'dart:io';
import 'configuration.dart';
import 'log.dart';
import 'package:msix/src/extensions.dart';

const runnerRcPath = 'windows/runner/Runner.rc';

/// Handles windows (pre-)build steps.
class WindowsBuild {
  Configuration _config;
  Log _log;

  WindowsBuild(this._config, this._log);

  /// Run "flutter build windows" command
  Future<void> build() async {
    const taskName = 'running "flutter build windows" command';
    _log.startingTask(taskName);

    var result =
        await Process.run('flutter', ['build', 'windows'], runInShell: true);

    if (result.exitCode != 0) {
      throw result.stdout;
    }
    _log.taskCompleted(taskName);
  }

  /// Update the company name 'com.example' in the Runner.rc file
  Future<void> updateRunnerCompanyName() async {
    if (!_config.updateCompanyName ||
        _config.identityName.isNull ||
        await File(runnerRcPath).exists() == false) return;

    var taskName =
        'updating Runner.rc "CompanyName" to "${_config.identityName}"';
    _log.startingTask(taskName);

    try {
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
    } catch (e) {
      _log.warn(
          'Failed to update company name "com.example" in windows/runner/Runner.rc');
      _log.warn(e.toString());
    }

    _log.taskCompleted(taskName);
  }
}
