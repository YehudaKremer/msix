import 'package:ansicolor/ansicolor.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/makePri.dart';
import 'src/appxManifest.dart';
import 'src/makeAppx.dart';
import 'src/signTool.dart';
import 'src/log.dart';

class Msix {
  Log _log = Log();
  late Configuration _config;

  Msix() {
    ansiColorDisabled = false;
    _config = Configuration(_log);
  }

  static void registerWith() {
    print(
        '-----> "MSIX" package needs to be under development dependencies (dev_dependencies) <-----');
  }

  /// Create and sign msix installer file
  Future<void> createMsix(List<String> cliArguments) async {
    await _config.getConfigValues(cliArguments);

    final _assets = Assets(_config, _log);
    final _signTool = SignTool(_config, _log);

    await _config.validateConfigValues();
    await _assets.cleanTemporaryFiles(clearMsixFiles: true);
    await _assets.copyAssetsFolder();
    await _assets.createIconsFolder();
    await _assets.copyIcons();
    await _assets.copyVCLibsFiles();
    if (!_config.store) {
      await _signTool.getCertificatePublisher(false);
    }
    await AppxManifest(_config, _log).generateAppxManifest();
    await MakePri(_config, _log).generatePRI();
    await MakeAppx(_config, _log).pack();
    await _assets.cleanTemporaryFiles();
    if (!_config.store) {
      if (!_config.dontInstallCert) {
        await _signTool.installCertificate();
      }
      await _signTool.sign();
    }

    _log.success('Msix Installer Created:');
    _log.link(
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix'
            .replaceAll('/', r'\'));
  }
}
