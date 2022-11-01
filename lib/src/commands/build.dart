import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/method_extensions.dart';

import '../msix.dart';

/// Execute with the `msix build` command
class BuildCommand extends Command {
  @override
  final String name = "build";
  @override
  final String description =
      "Build and create the necessary files to create a Msix package.";
  late Logger _logger;
  late Msix _msix;

  BuildCommand() {
    // TODO do "GetIt.I<Logger>" need to be in the constractor?
    _logger = GetIt.I<Logger>();
    _msix = GetIt.I<Msix>();
  }

  @override
  Future<void> run() async {
    await _msix.loadConfigurations();
    await _msix.buildMsixFiles();
    String msixStyledPath =
        File(_msix.msixOutputPath).parent.path.blue.emphasized;
    _logger
        .write('${'unpackaged msix files created in: '.green}$msixStyledPath');
  }
}
