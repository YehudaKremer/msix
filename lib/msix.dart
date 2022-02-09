import 'package:msix/src/appInstaller.dart';
import 'package:msix/src/windowsBuild.dart';
import 'package:cli_util/cli_logging.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/makePri.dart';
import 'src/appxManifest.dart';
import 'src/makeAppx.dart';
import 'src/signTool.dart';
import 'src/extensions.dart';

class Msix {
  late Logger _logger;

  late Configuration _config;

  Msix(List<String> arguments) {
    _logger = arguments.contains('-v')
        ? Logger.verbose()
        : Logger.standard(ansi: Ansi(true));
    _config = Configuration(arguments, _logger);
  }

  /// Print if msix is under dependencies instead of dev_dependencies
  static void registerWith() {
    print(
        '-----> "MSIX" package needs to be under development dependencies (dev_dependencies) <-----');
  }

  Future<void> create() async {
    await _initConfig();
    await _createMsix();

    _logger.write('msix created: '.green.emphasized);
    _logger.stdout(_config.msixPath
        .substring(_config.msixPath.indexOf('build/windows'))
        .blue
        .emphasized
        .replaceAll('/', r'\'));
  }

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
    await WindowsBuild(_config, _logger).build();

    var loggerProgress = _logger.progress('creating msix installer');

    await _config.validateBuildFiles();

    final _assets = Assets(_config, _logger);
    final _signTool = SignTool(_config, _logger);

    await _assets.cleanTemporaryFiles(clearMsixFiles: true);
    await _assets.createIconsFolder();
    await _assets.copyIcons();
    await _assets.copyVCLibsFiles();
    if (!_config.store) {
      await _signTool.getCertificatePublisher();
    }
    await AppxManifest(_config, _logger).generateAppxManifest();
    await MakePri(_config, _logger).generatePRI();
    await MakeAppx(_config, _logger).pack();
    await _assets.cleanTemporaryFiles();

    if (!_config.store) {
      if (_config.installCert) await _signTool.installCertificate();
      await _signTool.sign();
    }

    loggerProgress.finish(showTiming: true);
  }
}
