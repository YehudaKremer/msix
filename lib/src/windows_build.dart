import 'dart:io';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'method_extensions.dart';
import 'configuration.dart';

/// Handles windows files build steps
class WindowsBuild {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// Run "flutter build windows" command
  Future<void> build() async {
    List<String> buildWindowsArguments = ['build', 'windows'];

    if (_config.windowsBuildArgs != null) {
      buildWindowsArguments.addAll(_config.windowsBuildArgs!);
    }

    if (_config.createWithDebugBuildFiles) buildWindowsArguments.add('--debug');

    Progress loggerProgress = _logger
        .progress('running "flutter ${buildWindowsArguments.join(' ')}"');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run('flutter', buildWindowsArguments, runInShell: true)
      ..exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}
