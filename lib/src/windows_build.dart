import 'dart:io';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'method_extensions.dart';
import 'configuration.dart';

/// Handles windows files build steps
class WindowsBuild {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// Run "flutter build windows" command
  Future<void> build() async {
    final flutterArgs = [
      'build',
      'windows',
      ...?_config.windowsBuildArgs,
      if (_config.createWithDebugBuildFiles) '--debug',
    ];

    // e.g. C:\Users\MyUser\fvm\versions\3.7.12\bin\cache\dart-sdk\bin\dart.exe
    final dartPath = p.split(Platform.executable);

    // e.g. C:\Users\MyUser\fvm\versions\3.7.12\bin\flutter
    final flutterPath = p.joinAll([
      ...dartPath.sublist(0, dartPath.length - 4),
      'flutter',
    ]);

    final Progress loggerProgress = _logger
        .progress('running ""$flutterPath" ${flutterArgs.join(' ')}"');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run(flutterPath, flutterArgs, runInShell: true)
      ..exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}
