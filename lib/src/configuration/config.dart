import 'arg_config.dart';
import 'commands.dart';

//TODO add comments
class Config {
  final String arg;
  final String? _yaml;
  String? get yaml => _yaml ?? arg.replaceAll('-', '_');

  final List<Commands> useInCommands;
  final String? yamlPath;
  final ArgConfig? argConfig;

  const Config(
      {required this.arg,
      String? yaml,
      required this.useInCommands,
      this.yamlPath,
      this.argConfig})
      : _yaml = yaml;
}
