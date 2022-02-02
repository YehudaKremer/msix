import 'dart:io';
import 'configuration.dart';
import 'log.dart';

/// Use the makepri.exe tool to generate package resource indexing files
class MakePri {
  Configuration _config;
  Log _log;

  MakePri(this._config, this._log);

  Future<void> generatePRI() async {
    const taskName = 'generate package resource indexing files';
    _log.startingTask(taskName);

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

    if (result.stderr.toString().length > 0) {
      _log.error(result.stdout);
      throw result.stderr;
    } else if (result.exitCode != 0) {
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

    if (result.stderr.toString().length > 0) {
      _log.error(result.stdout);
      throw result.stderr;
    } else if (result.exitCode != 0) {
      throw result.stdout;
    }

    _log.taskCompleted(taskName);
  }
}
