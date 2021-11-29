import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class MakePri {
  static void generatePRI() {
    const taskName = 'generate PRI file';
    Log.startingTask(taskName);
    final _config = injector.get<Configuration>();

    if (!_config.haveAnyIconFromUser()) {
      var makepriPath =
          '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makepri.exe';

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
        Log.errorAndExit(result.stderr);
      } else if (result.exitCode != 0) {
        Log.errorAndExit(result.stdout);
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
        Log.errorAndExit(result.stderr);
      } else if (result.exitCode != 0) {
        Log.errorAndExit(result.stdout);
      }
    }
    Log.taskCompleted(taskName);
  }
}
