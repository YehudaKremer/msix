import 'dart:io';
import 'log.dart';
import 'configuration.dart';

class Makeappx {
  Configuration _config;

  Makeappx(this._config);

  void pack() {
    Log.startTask('packing');

    var msixPath = '${_config.buildFilesFolder}\\${_config.appName}.msix';
    var makeappxPath = '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makeappx.exe';

    if (File(msixPath).existsSync()) File(msixPath).deleteSync();

    var result = Process.runSync(makeappxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      _config.buildFilesFolder,
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
