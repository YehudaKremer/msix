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

    await _updateRunnerCompanyName();

    var result =
        await Process.run('flutter', ['build', 'windows'], runInShell: true);

    if (result.stderr.toString().length > 0) {
      _log.error(result.stdout);
      throw result.stderr;
    } else if (result.exitCode != 0) {
      throw result.stdout;
    }
    _log.taskCompleted(taskName);
  }

  /// Update the company name 'com.example' in the Runner.rc file
  Future<void> _updateRunnerCompanyName() async {
    if (_config.identityName.isNull) return;

    try {
      var runnerRcExists = await File(runnerRcPath).exists();
      if (runnerRcExists) {
        var runnerRcContent = await File(runnerRcPath).readAsString();
        var runnerRcUpdatedContent =
            runnerRcContent.replaceAll('com.example', _config.identityName!);
        await File(runnerRcPath).writeAsString(runnerRcUpdatedContent);
      }
    } catch (e) {
      _log.warn(
          'Failed to update company name "com.example" in windows/runner/Runner.rc');
      _log.warn(e.toString());
    }
  }
}
