import 'package:ansicolor/ansicolor.dart';
import 'src/log.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/extensions.dart';
import 'src/makepri.dart';
import 'src/manifest.dart';
import 'src/makeappx.dart';
import 'src/signtool.dart';

class Msix {
  late Log log;
  late Configuration _config;
  late Assets _assets;

  Msix() {
    ansiColorDisabled = false;
    _config = Configuration();
    _assets = Assets(_config);
  }

  /// Create and sign msix installer file
  Future<void> createMsix(List<String> cliArguments) async {
    await _config.getConfigValues(cliArguments);
    _config.validateConfigValues();
    _assets.cleanTemporaryFiles();
    _assets.createIconsFolder();
    _assets.copyIcons();
    _assets.copyVCLibsFiles();
    Manifest(_config)..generateAppxManifest();

    if (!_config.vsGeneratedImagesFolderPath.isNull) {
      Makepri(_config)..generatePRI();
    }

    Makeappx(_config)..pack();
    Signtool(_config)..sign();
    _assets.cleanTemporaryFiles();

    Log.success('Msix installer created here:');
    Log.link('${_config.buildFilesFolder}\\${_config.appName}.msix'.replaceAll('/', r'\'));

    if (_config.isUsingTestCertificate) Log.printTestCertificateHelp(_config.certificatePath!);
  }
}
