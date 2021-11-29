import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class MakeAppx {
  static void pack() {
    const taskName = 'packing';
    Log.startingTask(taskName);
    final _config = injector.get<Configuration>();
    var msixPath =
        '${_config.outputPath ?? _config.buildFilesFolder}/${_config.outputName ?? _config.appName}.msix';
    var makeAppxPath =
        '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makeappx.exe';

    var result = Process.runSync(makeAppxPath,
        ['pack', '/v', '/o', '/d', _config.buildFilesFolder, '/p', msixPath]);

    if (result.stderr.toString().length > 0) {
      Log.error(result.stdout);
      Log.errorAndExit(result.stderr);
    } else if (result.exitCode != 0) {
      Log.errorAndExit(result.stdout);
    }
    Log.taskCompleted(taskName);
  }
}
