import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'method_extensions.dart';
import 'configuration.dart';

/// Use the makeappx.exe tool to generate manifest file
class MakeAppx {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  Future<void> pack() async {
    _logger.trace('packing');

    String makeAppxPath = p.join(_config.msixToolkitPath, 'makeappx.exe');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run(makeAppxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      _config.buildFilesFolder,
      '/p',
      _config.msixPath
    ])
      ..exitOnError();
  }
}
