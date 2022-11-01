import 'dart:io';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/extensions.dart';

import 'configuration.dart';

const runnerRcPath = 'windows/runner/Runner.rc';
const mainCppPath = 'windows/runner/main.cpp';

/// Handles windows files build steps
class WindowsBuild {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// Run "flutter build windows" command
  Future<void> build() async {
    List<String> buildWindowsArguments = ['build', 'windows'];
    if (_config.createWithDebugBuildFiles) buildWindowsArguments.add('--debug');

    Progress loggerProgress = _logger
        .progress('running "flutter ${buildWindowsArguments.join(' ')}"');

    ProcessResult windowsBuildProcess =
        await Process.run('flutter', buildWindowsArguments, runInShell: true);

    windowsBuildProcess.exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}
