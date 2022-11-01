import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'windows_build.dart';
import 'configuration.dart';
import 'assets.dart';
import 'makepri.dart';
import 'appx_manifest.dart';
import 'makeappx.dart';
import 'sign_tool.dart';
import 'method_extensions.dart';

/// Main class that handles all the msix package functionality
class Msix {
  late Logger _logger;
  late Configuration _config;
  late SignTool _signTool;

  Msix() {
    _logger = GetIt.I<Logger>();
    _config = GetIt.I<Configuration>();
    _signTool = GetIt.I<SignTool>();
  }

  String get msixOutputPath => _config.msixPath.contains('build/windows')
      ? _config.msixPath.substring(_config.msixPath.indexOf('build/windows'))
      : _config.msixPath;

  Future<void> loadConfigurations() async {
    await _config.getConfigValues();
    await _config.validateConfigValues();
  }

  Future<void> createMsix() async {
    await buildMsixFiles();
    await packMsixFiles();
  }

  Future<void> buildMsixFiles() async {
    if (_config.buildWindows) await WindowsBuild().build();

    Progress loggerProgress = _logger.progress('building msix files');

    await _config.validateWindowsBuildFiles();
    Assets assets = Assets();
    await assets.cleanTemporaryFiles(clearMsixFiles: true);
    await assets.createIcons();
    await assets.copyVCLibsFiles();

    if (_config.signMsix && !_config.store) {
      await _signTool.getCertificatePublisher();
    }
    await AppxManifest().generateAppxManifest();
    await MakePri().generatePRI();

    loggerProgress.finish(showTiming: true);
  }

  Future<void> packMsixFiles() async {
    Progress loggerProgress = _logger.progress('packing msix files');

    await MakeAppx().pack();
    await Assets().cleanTemporaryFiles();

    if (_config.signMsix && !_config.store) {
      if (_config.installCert &&
          (_config.signToolOptions == null ||
              _config.signToolOptions!.isEmpty)) {
        await _signTool.installCertificate();
      }

      await _signTool.sign();
    }

    loggerProgress.finish(showTiming: true);
  }

  /// print the location of the created msix file
  void printMsixOutputLocation() => _logger
      .write('${'msix created: '.green}${msixOutputPath.blue.emphasized}');

  static void registerWith() {}
}
