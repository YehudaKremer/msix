import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class Makepri {
  static void generatePRI() {
    Log.startTask('generate PRI file');
    final config = injector.get<Configuration>();
    var msixPath = '${config.buildFilesFolder}\\${config.appName}.msix';
    var makepriPath = '${config.msixToolkitPath()}/Redist.${config.architecture}/makepri.exe';

    if (File(msixPath).existsSync()) File(msixPath).deleteSync();

    var result = Process.runSync(makepriPath,
        ['createconfig', '/cf', '${config.buildFilesFolder}\\priconfig.xml', '/dq', 'en-US', '/o']);

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
      '${config.buildFilesFolder}\\priconfig.xml',
      '/pr',
      config.buildFilesFolder,
      '/mn',
      '${config.buildFilesFolder}\\AppxManifest.xml',
      '/of',
      '${config.buildFilesFolder}\\resources.pri',
      '/o',
    ]);

    var priconfig = File('${config.buildFilesFolder}/priconfig.xml');
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
