import 'dart:io';

import 'package:cli_util/cli_logging.dart' show Logger, Ansi;
import 'src/app_installer.dart';
import 'src/windows_build.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/makepri.dart';
import 'src/appx_manifest.dart';
import 'src/makeappx.dart';
import 'src/sign_tool.dart';
import 'src/extensions.dart';

/// Handles all the msix package functionality
class Msix {
  late Logger _logger;
  late Configuration _config;

  Msix(List<String> arguments) {
    _logger = arguments.contains('-v')
        ? Logger.verbose()
        : Logger.standard(ansi: Ansi(true));
    _config = Configuration(arguments, _logger);
  }

  static void registerWith() {}

  /// Execute with the `msix:build` command
  Future<void> build() async {
    await _initConfig();

    var loggerProgress = _logger.progress('building msix files');
    await _buildMsixFiles();
    loggerProgress.finish(showTiming: true);

    final msixPath = _config.msixPath.contains('build/windows')
        ? _config.msixPath.substring(_config.msixPath.indexOf('build/windows'))
        : _config.msixPath;
    _logger.write('unpackaged msix files created in: ');
    _logger.stdout(
        File(msixPath).parent.path.blue.emphasized.replaceAll('/', r'\'));
  }

  /// Execute with the `msix:pack` command
  Future<void> pack() async {
    await _initConfig();

    /// check if the appx manifest is exist
    var appxManifestPath = '${_config.buildFilesFolder}/AppxManifest.xml';
    if (!(await File(appxManifestPath).exists())) {
      var error = 'run "msix:build" first';
      _logger.stderr(error.red);
      exit(-1);
    }

    var loggerProgress = _logger.progress('packing msix files');
    if (_config.signMsix && !_config.store) {
      await SignTool(_config, _logger).getCertificatePublisher();
    }
    await _packMsixFiles();
    loggerProgress.finish(showTiming: true);

    _printMsixOutputLocation();
  }

  /// Execute with the `msix:create` command
  Future<void> create() async {
    await _initConfig();
    await _createMsix();
    _printMsixOutputLocation();
  }

  /// Execute with the `msix:publish` command
  Future<void> publish() async {
    await _initConfig();
    await _config.validateAppInstallerConfigValues();
    var appInstaller = AppInstaller(_config, _logger);
    await appInstaller.validatePublishVersion();

    await _createMsix();

    var loggerProgress = _logger.progress('publishing');
    await appInstaller.copyMsixToVersionsFolder();
    await appInstaller.generateAppInstaller();
    await appInstaller.generateAppInstallerWebSite();
    loggerProgress.finish(showTiming: true);

    _logger.write('appinstaller created: '.green.emphasized);
    _logger
        .stdout(_config.appInstallerPath.blue.emphasized.replaceAll('/', r'\'));
  }

  Future<void> _initConfig() async {
    await _config.getConfigValues();
    await _config.validateConfigValues();
  }

  Future<void> _createMsix() async {
    var loggerProgress = _logger.progress('creating msix installer');
    await _buildMsixFiles();
    await _packMsixFiles();
    loggerProgress.finish(showTiming: true);
  }

  Future<void> _buildMsixFiles() async {
    if (_config.buildWindows) {
      await WindowsBuild(_config, _logger).build();
    }

    await _config.validateWindowsBuildFiles();
    final assets = Assets(_config, _logger);
    await assets.cleanTemporaryFiles(clearMsixFiles: true);
    await assets.createIcons();
    await assets.copyVCLibsFiles();

    if (_config.signMsix && !_config.store) {
      await SignTool(_config, _logger).getCertificatePublisher();
    }
    await AppxManifest(_config, _logger).generateAppxManifest();
    await MakePri(_config, _logger).generatePRI();
  }

  Future<void> _packMsixFiles() async {
    await MakeAppx(_config, _logger).pack();
    await Assets(_config, _logger).cleanTemporaryFiles();

    if (_config.signMsix && !_config.store) {
      final signTool = SignTool(_config, _logger);
      if (_config.installCert) await signTool.installCertificate();
      await signTool.sign();
    }
  }

  /// print the location of the created msix file
  void _printMsixOutputLocation() {
    _logger.write('msix created: '.green.emphasized);
    _logger.stdout((_config.msixPath.contains('build/windows')
            ? _config.msixPath
                .substring(_config.msixPath.indexOf('build/windows'))
            : _config.msixPath)
        .blue
        .emphasized
        .replaceAll('/', r'\'));
  }
}
