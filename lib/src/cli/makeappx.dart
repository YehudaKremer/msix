import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class Makeappx {
  static void pack() {
    const taskName = 'packing';
    Log.startingTask(taskName);
    final config = injector.get<Configuration>();
    var msixPath = '${config.buildFilesFolder}/${config.appName}.msix';
    var makeappxPath =
        '${config.msixToolkitPath()}/Redist.${config.architecture}/makeappx.exe';

    var result = Process.runSync(makeappxPath,
        ['pack', '/v', '/o', '/d', config.buildFilesFolder, '/p', msixPath]);

    if (result.stderr.toString().length > 0) {
      Log.error(result.stdout);
      Log.errorAndExit(result.stderr);
    } else if (result.exitCode != 0) {
      Log.errorAndExit(result.stdout);
    }
    Log.taskCompleted(taskName);
  }
}
