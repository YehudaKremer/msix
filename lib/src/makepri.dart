import 'dart:io';
import 'log.dart';
import 'configuration.dart';

class Makepri {
  Configuration _config;

  Makepri(this._config);

  void generatePRI() {
    Log.startTask('generate PRI file');

    var msixPath = '${_config.buildFilesFolder}\\${_config.appName}.msix';
    var makepriPath = '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makepri.exe';

    if (File(msixPath).existsSync()) File(msixPath).deleteSync();

    var result = Process.runSync(makepriPath, [
      'createconfig',
      '/cf',
      '${_config.buildFilesFolder}\\priconfig.xml',
      '/dq',
      'en-US',
      '/o'
    ]);

    if (result.stderr.toString().length > 0) {
      Log.error(result.stdout);
      Log.error(result.stderr);
      exit(0);
    } else if (result.exitCode != 0) {
      Log.error(result.stdout);
      exit(0);
    }

    result = Process.runSync(makepriPath, [
      'new',
      '/cf',
      '${_config.buildFilesFolder}\\priconfig.xml',
      '/pr',
      _config.buildFilesFolder,
      '/mn',
      '${_config.buildFilesFolder}\\AppxManifest.xml',
      '/of',
      '${_config.buildFilesFolder}\\resources.pri',
      '/o',
    ]);

    var priconfig = File('${_config.buildFilesFolder}/priconfig.xml');
    if (priconfig.existsSync()) priconfig.deleteSync();

    if (result.stderr.toString().length > 0) {
      Log.error(result.stdout);
      Log.error(result.stderr);
      exit(0);
    } else if (result.exitCode != 0) {
      Log.error(result.stdout);
      exit(0);
    }

    Log.completeTask();
  }
}
