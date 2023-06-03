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

    var flutterPath = await GetFlutterPath();

    final Progress loggerProgress =
        _logger.progress('running "flutter ${flutterArgs.join(' ')}"');

    _logger.trace('build windows files with the command: ' +
        '"$flutterPath ${flutterArgs.join(' ')}"');

    await Process.run(flutterPath, flutterArgs, runInShell: true)
      ..exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}

Future<String> GetFlutterPath() async {
  // use environment-variable 'flutter' by default
  var flutterPath = 'flutter';

  // e.g. C:\Users\MyUser\fvm\versions\3.7.12\bin\cache\dart-sdk\bin\dart.exe
  final dartPath = p.split(Platform.executable);

  // if contains 'cache\dart-sdk' we can know where is the 'flutter' located
  if (dartPath.contains('dart-sdk') && dartPath.length > 4) {
    // e.g. C:\Users\MyUser\fvm\versions\3.7.12\bin\flutter
    final flutterRelativePath = p.joinAll([
      ...dartPath.sublist(0, dartPath.length - 4),
      flutterPath,
    ]);

    if (await File(flutterRelativePath).exists()) {
      flutterPath = flutterRelativePath;
    }
  }

  return flutterPath;
}
