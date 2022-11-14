import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';

import 'configuration.dart';
import 'method_extensions.dart';

const runnerRcPath = 'windows/runner/Runner.rc';
const mainCppPath = 'windows/runner/main.cpp';

/// Handles windows files build steps
class WindowsBuild {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// Run "flutter build windows" command
  Future<void> build() async {
    List<String> buildWindowsArguments = ['build', 'windows'];
    if (_config.createWithDebugBuildFiles) {
      buildWindowsArguments.add('--debug');
    } else if (_config.obfuscate) {
      buildWindowsArguments.addAll([
        '--obfuscate',
        '--split-debug-info=${_config.debugSymbolsDirectory}',
      ]);
    }

    Progress loggerProgress = _logger
        .progress('running "flutter ${buildWindowsArguments.join(' ')}"');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run('flutter', buildWindowsArguments, runInShell: true)
      ..exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}
