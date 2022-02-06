import 'dart:io';
import 'configuration.dart';
import 'package:cli_util/cli_logging.dart';

/// Use the makeappx.exe tool to generate manifest file
class MakeAppx {
  Configuration _config;
  Logger _logger;

  MakeAppx(this._config, this._logger);

  Future<void> pack() async {
    _logger.trace('packing');

    var msixPath =
        '${_config.outputPath ?? _config.buildFilesFolder}/${_config.outputName ?? _config.appName}.msix';
    var makeAppxPath =
        '${_config.msixToolkitPath()}/Redist.${_config.architecture}/makeappx.exe';

    var result = await Process.run(makeAppxPath,
        ['pack', '/v', '/o', '/d', _config.buildFilesFolder, '/p', msixPath]);

    if (result.exitCode != 0) {
      throw result.stdout;
    }
  }
}
