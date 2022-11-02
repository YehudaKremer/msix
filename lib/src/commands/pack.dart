import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/method_extensions.dart';

import '../configuration.dart';
import '../msix.dart';
import '../sign_tool.dart';

/// Execute with the `msix pack` command
class PackCommand extends Command {
  @override
  final String name = "pack";
  @override
  final String description =
      "Create Msix package from files that created by the \"build\" command.";
  late Logger _logger;
  late Configuration _config;
  late SignTool _signTool;
  late Msix _msix;

  PackCommand() {
    _logger = GetIt.I<Logger>();
    _config = GetIt.I<Configuration>();
    _signTool = GetIt.I<SignTool>();
    _msix = GetIt.I<Msix>();
  }

  @override
  Future<void> run() async {
    await _msix.loadConfigurations();

    /// check if the appx manifest is exist
    String appxManifestPath = '${_config.buildFilesFolder}/AppxManifest.xml';
    if (!(await File(appxManifestPath).exists())) {
      String error = 'run "msix:build" first';
      _logger.stderr(error.red);
      exit(-1);
    }

    if (!_config.noSignMsix && !_config.store) {
      await _signTool.getCertificatePublisher();
    }
    await _msix.packMsixFiles();

    _msix.printMsixOutputLocation();
  }
}
