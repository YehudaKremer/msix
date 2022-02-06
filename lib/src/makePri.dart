import 'dart:io';
import 'configuration.dart';
import 'package:cli_util/cli_logging.dart';

/// Use the makepri.exe tool to generate package resource indexing files
class MakePri {
  Configuration _config;
  Logger _logger;

  MakePri(this._config, this._logger);

  Future<void> generatePRI() async {
    _logger.trace('generate package resource indexing files');

    final buildPath = _config.buildFilesFolder;
    var makePriPath =
        '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makepri.exe';

    var result = await Process.run(makePriPath, [
      'createconfig',
      '/cf',
      '$buildPath\\priconfig.xml',
      '/dq',
      'en-US',
      '/o'
    ]);

    if (result.exitCode != 0) {
      throw result.stdout;
    }

    result = await Process.run(makePriPath, [
      'new',
      '/cf',
      '$buildPath\\priconfig.xml',
      '/pr',
      buildPath,
      '/mn',
      '$buildPath\\AppxManifest.xml',
      '/of',
      '$buildPath\\resources.pri',
      '/o',
    ]);

    var priconfig = File('$buildPath/priconfig.xml');
    if (await priconfig.exists()) await priconfig.delete();

    if (result.exitCode != 0) {
      throw result.stdout;
    }
  }
}
