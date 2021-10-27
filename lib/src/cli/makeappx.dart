import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class MakeAppx {
  static void pack() {
    const taskName = 'packing';
    Log.startingTask(taskName);
    final config = injector.get<Configuration>();
    var msixPath =
        '${config.outputPath ?? config.buildFilesFolder}/${config.outputName ?? config.appName}.msix';
    var makeAppxPath =
        '${config.msixToolkitPath()}/Redist.${config.architecture}/makeappx.exe';

    var result = Process.runSync(makeAppxPath,
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
