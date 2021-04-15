import 'dart:io';
import 'injector.dart';
import 'log.dart';
import 'configuration.dart';

class Makeappx {
  static void pack() {
    Log.startTask('packing');
    final config = injector.get<Configuration>();
    var msixPath = '${config.buildFilesFolder}\\${config.appName}.msix';
    var makeappxPath = '${config.msixToolkitPath()}/Redist.${config.architecture}/makeappx.exe';

    if (File(msixPath).existsSync()) File(msixPath).deleteSync();

    var result = Process.runSync(makeappxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      config.buildFilesFolder,
      '/p',
      msixPath,
    ]);

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
