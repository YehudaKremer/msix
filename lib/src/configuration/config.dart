import 'arg_config.dart';
import 'commands.dart';

//TODO add comments
class Config {
  final String name;
  final List<Commands> useInCommands;
  final String? yamlPath;
  final ArgConfig? argConfig;

  const Config(
      {required this.name,
      required this.useInCommands,
      this.yamlPath,
      this.argConfig});
}
