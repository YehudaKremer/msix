import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/msix.dart';

import 'src/commands/build.dart';
import 'src/commands/create.dart';
import 'src/commands/pack.dart';
import 'src/commands/publish.dart';
import 'src/configuration.dart';
import 'src/sign_tool.dart';

void main(List<String> args) {
  var runner = CommandRunner(
      "msix", // TODO: check `valueHelp` and more in the addOption/flag method
      "A command line tool for creating MSIX installers from your Flutter app.")
    ..argParser.addOption('certificate-password',
        abbr: 'p', help: 'Password for the certificate.')
    ..argParser.addOption('certificate-path',
        abbr: 'c',
        help: 'Path to the certificate content to place in the store.')
    ..argParser.addOption('version',
        help: 'The version number of the package, in a.b.c.d format.')
    ..argParser.addOption('display-name',
        abbr: 'd',
        help:
            'A friendly name for the publisher that can be displayed to users.')
    ..argParser.addOption('publisher-display-name',
        abbr: 'u',
        help:
            'A friendly name for the publisher that can be displayed to users.')
    ..argParser.addOption('identity-name',
        abbr: 'i', help: 'Defines the unique identifier for the app.')
    ..argParser.addOption('publisher',
        abbr: 'b',
        help:
            'The Subject value in the certificate. Required only if publish to the store, or if the Publisher will not found automatically by this package.')
    ..argParser.addOption('logo-path',
        abbr: 'l',
        help:
            'Path to an image file for use as the app icon (size recommended at least 400x400px).')
    ..argParser.addOption('output-path',
        abbr: 'o',
        help: 'The directory where the output MSIX file should be stored.')
    ..argParser.addOption('output-name',
        abbr: 'n',
        help: 'The filename that should be given to the created MSIX file.')
    ..argParser.addOption('signtool-options',
        help:
            'Options to be provided to the signtool for app signing (see below.)')
    ..argParser.addOption('protocol-activation',
        help: 'Protocols activation that will activate the app.')
    ..argParser.addOption('execution-alias',
        help: 'Execution alias command (cmd) that will activate the app.')
    ..argParser.addOption('file-extension',
        abbr: 'f',
        help: 'File extensions that the app may be registered to open.')
    // TODO change 'h', getting error: 'Abbreviation "h" is already used by "help"'
    ..argParser.addOption('architecture',
        help:
            'Describes the architecture of the code in the package, x64 or x86, x64 is default.') // TODO: i deleted "abbr: 'h'"!!!
    ..argParser.addOption('capabilities',
        abbr: 'e', help: 'List of the capabilities the app requires.')
    ..argParser.addOption('languages',
        help: 'Declares the language resources contained in the package.')
    ..argParser.addOption('sign-msix',
        help:
            'If false, don\'t sign the msix file, default is true. Note: when false, publisher is Required.')
    ..argParser.addOption('install-certificate',
        help:
            'If false, don\'t try to install the certificate, default is true.')
    ..argParser.addOption('trim-logo',
        help: 'If false, don\'t trim the logo image, default is true.')
    ..argParser.addOption('toast-activator-clsid', help: 'The UUID CLSID.')
    ..argParser.addOption('toast-activator-arguments',
        help: 'Arguments for the toast notifications.')
    ..argParser.addOption('toast-activator-display-name',
        help: 'Display name for the toast notifications.')
    ..argParser.addOption('publish-folder-path',
        help:
            'A path to publish folder, where the msix versions and the .appinstaller file will be saved.')
    ..argParser.addOption('hours-between-update-checks',
        help:
            'Defines the minimal time gap between update checks, when the user open the app. default is 0 (will check for update every time the app opened)')
    ..argParser.addOption('build-windows',
        help:
            'If false, don\'t run the build command flutter build windows, default is true.')
    ..argParser.addOption('app-uri-handler-hosts',
        help: 'Enable apps for websites using app URI handlers app.')
    ..argParser.addFlag('store',
        help: 'Generate a MSIX file for publishing to the Microsoft Store.')
    ..argParser.addFlag('enable-at-startup',
        help: 'App start at startup or user log-in.')
    ..argParser.addFlag('debug',
        help:
            'Create MSIX from the debug build files (\\build\\windows\\runner\\debug), release is the default.')
    ..argParser.addFlag('release',
        help:
            'Create MSIX from the release build files (\\build\\windows\\runner\\release), release is the default.')
    ..argParser.addFlag('automatic-background-task',
        help:
            'Checks for updates in the background every 8 hours independently of whether the user launched the app.')
    ..argParser.addFlag('update-blocks-activation',
        help: 'Defines the experience when an app update is checked for.')
    ..argParser.addFlag('show-prompt',
        help:
            'Defines if a window is displayed when updates are being installed, and when updates are being checked for.')
    ..argParser.addFlag('force-update-from-any-version',
        help:
            'Allows the app to update from version x to version x++ or to downgrade from version x to version x--.');

  // exclude -v (verbose) from the arguments
  var parsedArgs = runner.parse(args.where((arg) => arg != '-v'));

  _setupSingletonServices(parsedArgs);

  runner
    ..addCommand(BuildCommand())
    ..addCommand(PackCommand())
    ..addCommand(CreateCommand())
    ..addCommand(PublishCommand());

  runner.run(args);
}

/// Register [Logger] and [Configuration] as singleton services
_setupSingletonServices(ArgResults args) {
  GetIt.I.registerSingleton<Logger>(args.arguments.contains('-v')
      ? Logger.verbose()
      : Logger.standard(ansi: Ansi(true)));

  GetIt.I.registerSingleton<Configuration>(Configuration(args));
  GetIt.I.registerSingleton<SignTool>(SignTool());

  //TODO: make Msix instance depends on Configuration insttace
  //so we dont need to invoke "_msix.loadConfigurations()"
  GetIt.I.registerSingleton<Msix>(Msix());
}
