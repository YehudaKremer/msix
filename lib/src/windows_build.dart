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

  /// Run the configured Windows build command
  Future<void> build() async {
    final tool = (_config.windowsBuildTool ?? 'flutter').toLowerCase().trim();
    switch (tool) {
      case 'shorebird':
        await _buildWithShorebird();
        return;
      case 'flutter':
      default:
        await _buildWithFlutter();
        return;
    }
  }

  Future<void> _buildWithFlutter() async {
    final flutterBuildArgs = [
      'build',
      'windows',
      ...?_config.windowsBuildArgs,
      if (_config.createWithDebugBuildFiles) '--debug',
    ];

    var flutterPath = await _getFlutterPath();

    final Progress loggerProgress =
        _logger.progress('running "flutter ${flutterBuildArgs.join(' ')}"');

    _logger.trace(
      'build windows files with the command: '
      '"$flutterPath ${flutterBuildArgs.join(' ')}"',
    );

    ProcessResult buildProcess =
        await Process.run(flutterPath, flutterBuildArgs, runInShell: true);

    buildProcess.exitOnError();

    loggerProgress.finish(showTiming: true);
  }

  Future<void> _buildWithShorebird() async {
    final shorebirdArgs = <String>[
      'release',
      'windows',
      ...?_config.shorebirdArgs,
    ];

    var shorebirdPath = await _getShorebirdPath();

    final Progress loggerProgress =
        _logger.progress('running "shorebird ${shorebirdArgs.join(' ')}"');

    _logger.trace(
      'build windows files with the command: '
      '"$shorebirdPath ${shorebirdArgs.join(' ')}"',
    );

    ProcessResult buildProcess =
        await Process.run(shorebirdPath, shorebirdArgs, runInShell: true);

    buildProcess.exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}

Future<String> _getFlutterPath() async {
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

Future<String> _getShorebirdPath() async {
  // Respect explicit override first (if user wants a specific binary path)
  final override = Platform.environment['SHOREBIRD_BIN'];
  if (override != null && override.trim().isNotEmpty) {
    return override.trim();
  }

  // default to 'shorebird' on PATH
  var shorebirdPath = 'shorebird';

  // Try to resolve using the Dart SDK path (similar to flutter discovery above)
  final dartPath = p.split(Platform.executable);
  if (dartPath.contains('dart-sdk') && dartPath.length > 4) {
    final shorebirdRelativePath = p.joinAll([
      ...dartPath.sublist(0, dartPath.length - 4),
      'shorebird',
    ]);

    if (await File(shorebirdRelativePath).exists()) {
      shorebirdPath = shorebirdRelativePath;
    }
  }

  return shorebirdPath;
}
