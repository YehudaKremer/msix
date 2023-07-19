import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'src/app_installer.dart';
import 'src/windows_build.dart';
import 'src/configuration.dart';
import 'src/assets.dart';
import 'src/makepri.dart';
import 'src/appx_manifest.dart';
import 'src/makeappx.dart';
import 'src/sign_tool.dart';
import 'src/method_extensions.dart';

/// Main class that handles all the msix package functionality
class Msix {
  late Logger _logger;
  late Configuration _config;

  Msix(List<String> args) {
    _setupSingletonServices(args);
    _logger = GetIt.I<Logger>();
    _config = GetIt.I<Configuration>();
  }

  /// Execute with the `msix:build` command
  Future<void> build() async {
    await _initConfig();
    await _buildMsixFiles();
    String msixStyledPath = File(_msixOutputPath).parent.path.blue.emphasized;
    _logger
        .write('${'unpackaged msix files created in: '.green}$msixStyledPath');
  }

  /// Execute with the `msix:pack` command
  Future<void> pack() async {
    await _initConfig();

    /// check if the appx manifest is exist
    String appxManifestPath =
        p.join(_config.buildFilesFolder, 'AppxManifest.xml');
    if (!(await File(appxManifestPath).exists())) {
      String error = 'run "msix:build" first';
      _logger.stderr(error.red);
      exit(-1);
    }

    if (_config.signMsix && !_config.store) {
      await SignTool().getCertificatePublisher();
    }
    await _packMsixFiles();

    _printMsixOutputLocation();
  }

  /// Execute with the `msix:create` command
  Future<void> create() async {
    await _initConfig();
    await _createMsix();
    _printMsixOutputLocation();
  }

  /// Execute with the `msix:publish` command
  Future<void> publish() async {
    await _initConfig();
    await _config.validateAppInstallerConfigValues();
    AppInstaller appInstaller = AppInstaller();
    await appInstaller.validatePublishVersion();

    await _createMsix();

    Progress loggerProgress = _logger.progress('publishing');
    await appInstaller.copyMsixToVersionsFolder();
    await appInstaller.generateAppInstaller();
    await appInstaller.generateAppInstallerWebSite();
    loggerProgress.finish(showTiming: true);
    _logger.write(
        '${'appinstaller created: '.green}${_config.appInstallerPath.blue.emphasized}');
  }

  /// Register [Logger] and [Configuration] as singleton services
  _setupSingletonServices(List<String> args) {
    GetIt.I.registerSingleton<Logger>(args.contains('-v')
        ? Logger.verbose()
        : Logger.standard(ansi: Ansi(true)));

    GetIt.I.registerSingleton<Configuration>(Configuration(args));
  }

  String get _msixOutputPath =>
      _config.msixPath.contains(p.join('build', 'windows'))
          ? _config.msixPath
              .substring(_config.msixPath.indexOf(p.join('build', 'windows')))
          : _config.msixPath;

  Future<void> _initConfig() async {
    await _config.getConfigValues();
    await _config.validateConfigValues();
  }

  Future<void> _createMsix() async {
    await _buildMsixFiles();
    await _packMsixFiles();
  }

  Future<void> _buildMsixFiles() async {
    if (_config.buildWindows) await WindowsBuild().build();

    Progress loggerProgress = _logger.progress('building msix files');

    await _config.validateWindowsBuildFiles();
    Assets assets = Assets();
    await assets.cleanTemporaryFiles(clearMsixFiles: true);
    await assets.createIcons();
    await assets.copyVCLibsFiles();

    if (_config.contextMenuConfiguration?.comSurrogateServers.isNotEmpty ==
        true) {
      for (var element
          in _config.contextMenuConfiguration!.comSurrogateServers) {
        await assets.copyContextMenuDll(element.dllPath);
      }
    }

    if (_config.signMsix && !_config.store) {
      await SignTool().getCertificatePublisher();
    }
    await AppxManifest().generateAppxManifest();
    await MakePri().generatePRI();

    loggerProgress.finish(showTiming: true);
  }

  Future<void> _packMsixFiles() async {
    Progress loggerProgress = _logger.progress('packing msix files');

    await MakeAppx().pack();
    await Assets().cleanTemporaryFiles();

    if (_config.signMsix && !_config.store) {
      SignTool signTool = SignTool();

      if (_config.installCert &&
          (_config.signToolOptions == null ||
              _config.signToolOptions!.isEmpty)) {
        await signTool.installCertificate();
      }

      await signTool.sign();
    }

    loggerProgress.finish(showTiming: true);
  }

  /// print the location of the created msix file
  void _printMsixOutputLocation() => _logger
      .write('${'msix created: '.green}${_msixOutputPath.blue.emphasized}');

  static void registerWith() {}
}
