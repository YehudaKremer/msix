import 'dart:io';
import 'package:cli_util/cli_logging.dart' show Logger;
import 'package:get_it/get_it.dart';

import 'configuration.dart';

const runnerRcPath = 'windows/runner/Runner.rc';
const mainCppPath = 'windows/runner/main.cpp';

/// Handles windows files build steps
class WindowsBuild {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// Run "flutter build windows" command
  Future<void> build() async {
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
  }
}
