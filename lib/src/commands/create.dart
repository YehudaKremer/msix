import 'package:args/command_runner.dart';
import 'package:get_it/get_it.dart';
import '../configuration/commands.dart';
import '../configuration/configuration.dart';
import '../msix.dart';

/// Execute with the `msix create` command
class CreateCommand extends Command {
  @override
  final String name = "create";
  @override
  final String description =
      "Build windows application and create Msix package for it.";
  late Msix _msix;

  CreateCommand() {
    _msix = GetIt.I<Msix>();

    Configuration.addArguments(Commands.create, argParser);
  }

  @override
  Future<void> run() async {
    await _msix.loadConfigurations();
    await _msix.createMsix();
    _msix.printMsixOutputLocation();
  }
}
