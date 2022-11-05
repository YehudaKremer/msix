import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/method_extensions.dart';

import '../app_installer.dart';
import '../configuration/configuration.dart';
import '../msix.dart';

/// Execute with the `msix publish` command
class PublishCommand extends Command {
  @override
  final String name = "publish";
  @override
  final String description =
      "Create and publish the Msix package with a \"App Installer\" file.";
  late Logger _logger;
  late Configuration _config;
  late Msix _msix;

  PublishCommand() {
    _logger = GetIt.I<Logger>();
    _config = GetIt.I<Configuration>();
    _msix = GetIt.I<Msix>();

    argParser.addOption('publish-folder-path',
        help:
            'A path to publish folder, where the msix versions and the .appinstaller file will be saved.',
        valueHelp: 'c:\\path\\to\\myPublishFolder');
    argParser.addOption('hours-between-update-checks',
        help:
            'Defines the minimal time gap between update checks, when the user open the app. default is 0 (will check for update every time the app opened)',
        valueHelp: '2');
    argParser.addFlag('automatic-background-task',
        help:
            'Checks for updates in the background every 8 hours independently of whether the user launched the app.');
    argParser.addFlag('update-blocks-activation',
        help: 'Defines the experience when an app update is checked for.');
    argParser.addFlag('show-prompt',
        help:
            'Defines if a window is displayed when updates are being installed, and when updates are being checked for.');
    argParser.addFlag('force-update-from-any-version',
        help:
            'Allows the app to update from version x to version x++ or to downgrade from version x to version x--.');
  }

  @override
  Future<void> run() async {
    await _msix.loadConfigurations();
    await _config.validateAppInstallerConfigValues();
    AppInstaller appInstaller = AppInstaller();
    await appInstaller.validatePublishVersion();

    await _msix.createMsix();

    Progress loggerProgress = _logger.progress('publishing');
    await appInstaller.copyMsixToVersionsFolder();
    await appInstaller.generateAppInstaller();
    await appInstaller.generateAppInstallerWebSite();
    loggerProgress.finish(showTiming: true);
    _logger.write(
        '${'appinstaller created: '.green}${_config.appInstallerPath.blue.emphasized}');
  }
}
