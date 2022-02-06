import 'package:msix/src/windowsBuild.dart';
import 'package:cli_util/cli_logging.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/makePri.dart';
import 'src/appxManifest.dart';
import 'src/makeAppx.dart';
import 'src/signTool.dart';

/// Execute all the steps to prepare an msix package
class Msix {
  late Logger _logger;

  /// Configuration instance for all sub classes instances
  late Configuration _config;

  /// User executes this with optional arguments:
  /// flutter pub run msix:create [cliArguments]
  /// or: flutter pub run msix:buildAndCreate [cliArguments]
  Msix(List<String> args) {
    _logger = args.contains('-v')
        ? Logger.verbose()
        : Logger.standard(ansi: Ansi(true));
    _config = Configuration(args, _logger);
  }

  /// Print if msix is under dependencies instead of dev_dependencies
  static void registerWith() {
    print(
        '-----> "MSIX" package needs to be under development dependencies (dev_dependencies) <-----');
  }

  Future<void> loadConfigurations() async {
    await _config.getConfigValues();
    await _config.validateConfigValues();
  }

  Future<void> buildWindowsFilesAndCreateMsix() async {
    await WindowsBuild(_config, _logger).updateRunnerCompanyName();
    await WindowsBuild(_config, _logger).build();
    await createMsix();
  }

  Future<void> createMsix() async {
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

    // If the package is intended for store publish
    // then don't install cert or sign the package
    if (!_config.store) {
      if (_config.installCert) await _signTool.installCertificate();
      await _signTool.sign();
    }

    loggerProgress.finish(showTiming: true);

    _logger.write('${Ansi(true).green}msix created:${Ansi(true).none} ');

    // Print the created msix installer path
    var installerPath =
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix';
    _logger.stdout(
        '${Ansi(true).blue}${installerPath.substring(installerPath.indexOf('build/windows'))}${Ansi(true).none}'
            .replaceAll('/', r'\'));
  }
}
