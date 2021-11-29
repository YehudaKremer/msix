import 'package:ansicolor/ansicolor.dart';
import 'src/utils/injector.dart';
import 'src/utils/log.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/cli/makepri.dart';
import 'src/manifest.dart';
import 'src/cli/makeappx.dart';
import 'src/cli/signtool.dart';

class Msix {
  Msix() {
    initInjector();
    ansiColorDisabled = false;
  }

  /// Create and sign msix installer file
  Future<void> createMsix(List<String> cliArguments) async {
    final _config = injector.get<Configuration>();
    await _config.getConfigValues(cliArguments);
    _config.validateConfigValues();
    final assets = Assets();
    assets.cleanTemporaryFiles(clearMsixFiles: true);
    assets.copyAssetsFolder();
    assets.createIconsFolder();
    assets.copyIcons();
    assets.copyVCLibsFiles();
    if (!_config.store) {
      Signtool.getCertificatePublisher(false);
    }
    Manifest()..generateAppxManifest();
    MakePri.generatePRI();
    MakeAppx.pack();
    assets.cleanTemporaryFiles();
    if (!_config.store) {
      if (!_config.dontInstallCert) {
        Signtool.installCertificate();
      }
      Signtool.sign();
    }

    Log.success('Msix Installer Created:');
    Log.link(
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix'
            .replaceAll('/', r'\'));
  }
}
