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
    final config = injector.get<Configuration>();
    await config.getConfigValues(cliArguments);
    config.validateConfigValues();
    final assets = Assets();
    assets.cleanTemporaryFiles(clearMsixFiles: true);
    assets.createIconsFolder();
    assets.copyIcons();
    assets.copyVCLibsFiles();
    Manifest()..generateAppxManifest();
    Makepri.generatePRI();
    Makeappx.pack();
    assets.cleanTemporaryFiles();
    if (!config.store) {
      Signtool.sign();
    }

    Log.success('Msix Installer Created:');
    Log.link('${config.buildFilesFolder}\\${config.appName}.msix'
        .replaceAll('/', r'\'));

    if (config.isUsingTestCertificate)
      Log.printTestCertificateHelp(config.certificatePath!);
  }
}
