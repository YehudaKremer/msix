import 'dart:io';
import 'package:cli_util/cli_logging.dart' show Logger;
import 'configuration.dart';

/// Use the makeappx.exe tool to generate manifest file
class MakeAppx {
  final Configuration _config;
  final Logger _logger;

  MakeAppx(this._config, this._logger);

  Future<void> pack() async {
    _logger.trace('packing');

    var makeAppxPath =
        '${_config.msixToolkitPath}/Redist.${_config.architecture}/makeappx.exe';

    var makeAppxProcess = await Process.run(makeAppxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      _config.buildFilesFolder,
      '/p',
      _config.msixPath
    ]);

    if (makeAppxProcess.exitCode != 0) {
      _logger.stderr(makeAppxProcess.stdout);
      throw makeAppxProcess.stderr;
    }
  }
}
