import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

import 'configuration.dart';
import 'method_extensions.dart';

/// Use the makeappx.exe tool to generate manifest file
class MakeAppx {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  Future<void> pack() async {
    _logger.trace('packing');

    String makeAppxPath = p.join(_config.msixToolkitPath, 'makeappx.exe');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run(makeAppxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      _config.buildFilesFolder,
      '/p',
      _config.msixPath
    ])
      ..exitOnError();

    if (_config.bundle) {
      _logger.trace('bundling');

      String outputDirectoryPath =
          _config.outputPath ?? _config.buildFilesFolder;

      // clear all files and folders in outputDirectoryPath except from .msix files

//delay 1 second
      await Future.delayed(const Duration(seconds: 1));

      await for (FileSystemEntity entity
          in Directory(outputDirectoryPath).list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.msix')) {
          continue;
        }
        await entity.delete(recursive: true);
      }

      // ignore: avoid_single_cascade_in_expression_statements
      await Process.run(makeAppxPath, [
        'bundle',
        '/d',
        _config.outputPath ?? _config.buildFilesFolder,
        '/p',
        "${_config.msixPath}bundle"
      ])
        ..exitOnError();
    }
  }
}
