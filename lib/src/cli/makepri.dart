import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class Makepri {
  static void generatePRI() {
    Log.startingTask('generate PRI file');
    final config = injector.get<Configuration>();

    if (!config.haveAnyIconFromUser()) {
      var makepriPath =
          '${config.msixToolkitPath()}/Redist.${config.architecture}/makepri.exe';

      var result = Process.runSync(makepriPath, [
        'createconfig',
        '/cf',
        '${config.buildFilesFolder}\\priconfig.xml',
        '/dq',
        'en-US',
        '/o'
      ]);

      if (result.stderr.toString().length > 0) {
        Log.error(result.stdout);
        Log.errorAndExit(result.stderr);
      } else if (result.exitCode != 0) {
        Log.errorAndExit(result.stdout);
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
        Log.errorAndExit(result.stderr);
      } else if (result.exitCode != 0) {
        Log.errorAndExit(result.stdout);
      }
    }
    Log.taskCompleted();
  }
}
