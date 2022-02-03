import 'package:ansicolor/ansicolor.dart' show ansiColorDisabled;
import 'package:msix/src/windowsBuild.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/makePri.dart';
import 'src/appxManifest.dart';
import 'src/makeAppx.dart';
import 'src/signTool.dart';
import 'src/log.dart';

/// Execute all the steps to prepare an msix package
class Msix {
  /// Log instance for all sub classes instances
  Log _log = Log();

  /// Configuration instance for all sub classes instances
  late Configuration _config;

  Msix() {
    // To enable colored logs
    ansiColorDisabled = false;

    _config = Configuration(_log);
  }

  /// Print if msix is under dependencies instead of dev_dependencies
  static void registerWith() {
    print(
        '-----> "MSIX" package needs to be under development dependencies (dev_dependencies) <-----');
  }

  /// User executes this with optional arguments:
  /// flutter pub run msix:create [cliArguments]
  /// or: flutter pub run msix:buildAndCreate [cliArguments]
  Future<void> loadConfigurations(List<String> cliArguments) async {
    await _config.getConfigValues(cliArguments);
    await _config.validateConfigValues();
  }

  Future<void> buildWindowsFilesAndCreateMsix() async {
    await WindowsBuild(_config, _log).updateRunnerCompanyName();
    await WindowsBuild(_config, _log).build();
    await createMsix();
  }

  Future<void> createMsix() async {
    await _config.validateBuildFiles();

    final _assets = Assets(_config, _log);
    final _signTool = SignTool(_config, _log);

    await _assets.cleanTemporaryFiles(clearMsixFiles: true);
    await _assets.createIconsFolder();
    await _assets.copyIcons();
    await _assets.copyVCLibsFiles();
    if (!_config.store) {
      await _signTool.getCertificatePublisher();
    }
    await AppxManifest(_config, _log).generateAppxManifest();
    await MakePri(_config, _log).generatePRI();
    await MakeAppx(_config, _log).pack();
    await _assets.cleanTemporaryFiles();

    // If the package is intended for store publish
    // then don't install cert or sign the package
    if (!_config.store) {
      if (_config.installCert) await _signTool.installCertificate();
      await _signTool.sign();
    }

    _log.success('Msix Installer Created:');

    // Print the created msix installer path
    _log.link(
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix'
            .replaceAll('/', r'\'));
  }
}
