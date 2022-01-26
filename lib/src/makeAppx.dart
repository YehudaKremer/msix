import 'dart:io';
import 'configuration.dart';
import 'log.dart';

class MakeAppx {
  Configuration _config;
  Log _log;

  MakeAppx(this._config, this._log);

  Future<void> pack() async {
    const taskName = 'packing';
    _log.startingTask(taskName);

    var msixPath =
        '${_config.outputPath ?? _config.buildFilesFolder}/${_config.outputName ?? _config.appName}.msix';
    var makeAppxPath = '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makeappx.exe';

    var result = await Process.run(
        makeAppxPath, ['pack', '/v', '/o', '/d', _config.buildFilesFolder, '/p', msixPath]);

    if (result.stderr.toString().length > 0) {
      _log.error(result.stdout);
      _log.errorAndExit(result.stderr);
    } else if (result.exitCode != 0) {
      _log.errorAndExit(result.stdout);
    }
    _log.taskCompleted(taskName);
  }
}
