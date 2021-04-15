import 'package:ansicolor/ansicolor.dart';
import 'src/injector.dart';
import 'src/log.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/extensions.dart';
import 'src/makepri.dart';
import 'src/manifest.dart';
import 'src/makeappx.dart';
import 'src/signtool.dart';

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

    if (!config.vsGeneratedImagesFolderPath.isNull) {
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
