import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/method_extensions.dart';
import '../app_installer.dart';
import '../configuration/commands.dart';
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

    Configuration.addArguments(Commands.publish, argParser);
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
