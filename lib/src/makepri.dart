import 'dart:io';
import 'package:cli_util/cli_logging.dart' show Logger;
import 'package:get_it/get_it.dart';
import 'configuration.dart';
import 'extensions.dart';

/// Use the makepri.exe tool to generate package resource indexing files
class MakePri {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  Future<void> generatePRI() async {
    _logger.trace('generate package resource indexing files');

    final buildPath = _config.buildFilesFolder;
    var makePriPath =
        '${_config.msixToolkitPath}/Redist.${_config.architecture}/makepri.exe';

    var makePriConfigProcess = await Process.run(makePriPath, [
      'createconfig',
      '/cf',
      '$buildPath\\priconfig.xml',
      '/dq',
      'en-US',
      '/o'
    ]);

    makePriConfigProcess.exitOnError();

    var makePriProcess = await Process.run(makePriPath, [
      'new',
      '/cf',
      '$buildPath\\priconfig.xml',
      '/pr',
      buildPath,
      '/mn',
      '$buildPath\\AppxManifest.xml',
      '/of',
      '$buildPath\\resources.pri',
      '/o',
    ]);

    await File('$buildPath/priconfig.xml').deleteIfExists();

    makePriProcess.exitOnError();
  }
}
