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
    assets.cleanTemporaryFiles();
    assets.createIconsFolder();
    assets.copyIcons();
    assets.copyVCLibsFiles();

    Manifest()..generateAppxManifest();

    if (!config.haveAnyIconFromUser()) {
      Makepri.generatePRI();
    }

    Makeappx.pack();
    Signtool.sign();
    assets.cleanTemporaryFiles();

    Log.success('Msix installer created here:');
    Log.link('${config.buildFilesFolder}\\${config.appName}.msix'.replaceAll('/', r'\'));

    if (config.isUsingTestCertificate) Log.printTestCertificateHelp(config.certificatePath!);
  }
}
