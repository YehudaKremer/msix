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
  var runner = CommandRunner("msix",
      "A command line tool for creating MSIX installers from your Flutter app.")
    ..argParser.addOption('certificate-password', abbr: 'p')
    ..argParser.addOption('certificate-path', abbr: 'c')
    ..argParser.addOption('version')
    ..argParser.addOption('display-name', abbr: 'd')
    ..argParser.addOption('publisher-display-name', abbr: 'u')
    ..argParser.addOption('identity-name', abbr: 'i')
    ..argParser.addOption('publisher', abbr: 'b')
    ..argParser.addOption('logo-path', abbr: 'l')
    ..argParser.addOption('output-path', abbr: 'o')
    ..argParser.addOption('output-name', abbr: 'n')
    ..argParser.addOption('signtool-options')
    ..argParser.addOption('protocol-activation')
    ..argParser.addOption('execution-alias')
    ..argParser.addOption('file-extension', abbr: 'f')
    // TODO change 'h', getting error: 'Abbreviation "h" is already used by "help"'
    ..argParser.addOption('architecture') // TODO: i deleted "abbr: 'h'"!!!
    ..argParser.addOption('capabilities', abbr: 'e')
    ..argParser.addOption('languages')
    ..argParser.addOption('sign-msix')
    ..argParser.addOption('install-certificate')
    ..argParser.addOption('trim-logo')
    ..argParser.addOption('toast-activator-clsid')
    ..argParser.addOption('toast-activator-arguments')
    ..argParser.addOption('toast-activator-display-name')
    ..argParser.addOption('publish-folder-path')
    ..argParser.addOption('hours-between-update-checks')
    ..argParser.addOption('build-windows')
    ..argParser.addOption('app-uri-handler-hosts')
    ..argParser.addFlag('store')
    ..argParser.addFlag('enable-at-startup')
    ..argParser.addFlag('debug')
    ..argParser.addFlag('release')
    ..argParser.addFlag('automatic-background-task')
    ..argParser.addFlag('update-blocks-activation')
    ..argParser.addFlag('show-prompt')
    ..argParser.addFlag('force-update-from-any-version');

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
