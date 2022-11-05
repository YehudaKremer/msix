import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/msix.dart';

import 'src/commands/build.dart';
import 'src/commands/create.dart';
import 'src/commands/pack.dart';
import 'src/commands/publish.dart';
import 'src/configuration/configuration.dart';
import 'src/msix_command_runner.dart';
import 'src/sign_tool.dart';

void main(List<String> args) {
  print(args);

  var runner = msixCommandRunner;

  // exclude -v (verbose) from the arguments
  // TODO: dont exclude, try add '-v' as flag
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
