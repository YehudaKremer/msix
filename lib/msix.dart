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

  /// Execute when use the msix:create command
  Future<void> create() async {
    await _initConfig();
    await _createMsix();

    _logger.write('msix created: '.green.emphasized);
    _logger.stdout((_config.msixPath.contains('build/windows')
            ? _config.msixPath
                .substring(_config.msixPath.indexOf('build/windows'))
            : _config.msixPath)
        .blue
        .emphasized
        .replaceAll('/', r'\'));
  }

  /// Execute when use the msix:publish command
  Future<void> publish() async {
    await _initConfig();
    await _config.validateAppInstallerConfigValues();
    var appInstaller = AppInstaller(_config, _logger);
    await appInstaller.validatePublishVersion();

    await _createMsix();

    var loggerProgress = _logger.progress('publish');
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
    if (_config.buildWindows) {
      // run the "flutter build windows" command
      await WindowsBuild(_config, _logger).build();
    }

    var loggerProgress = _logger.progress('creating msix installer');

    // validate the "flutter build windows" output files
    await _config.validateBuildFiles();

    final _assets = Assets(_config, _logger);
    final _signTool = SignTool(_config, _logger);

    await _assets.cleanTemporaryFiles(clearMsixFiles: true);
    await _assets.createIcons();
    await _assets.copyVCLibsFiles();
    if (_config.signMsix && !_config.store) {
      await _signTool.getCertificatePublisher();
    }
    await AppxManifest(_config, _logger).generateAppxManifest();
    await MakePri(_config, _logger).generatePRI();
    await MakeAppx(_config, _logger).pack();
    await _assets.cleanTemporaryFiles();

    if (_config.signMsix && !_config.store) {
      if (_config.installCert) await _signTool.installCertificate();
      await _signTool.sign();
    }

    loggerProgress.finish(showTiming: true);
  }
}
