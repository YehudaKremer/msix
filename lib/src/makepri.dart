import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'configuration.dart';
import 'method_extensions.dart';

/// Use the makepri.exe tool to generate package resource indexing files
class MakePri {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  Future<void> generatePRI() async {
    _logger.trace('generate package resource indexing files');

    final String buildPath = _config.buildFilesFolder;
    String makePriPath = p.join(_config.msixToolkitPath, 'makepri.exe');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run(makePriPath, [
      'createconfig',
      '/cf',
      '$buildPath\\priconfig.xml',
      '/dq',
      'en-US',
      '/o'
    ])
      ..exitOnError();

    ProcessResult makePriProcess = await Process.run(makePriPath, [
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
