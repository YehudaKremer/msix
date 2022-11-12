import 'arg_config.dart';
import 'commands.dart';
import 'config_type.dart';

//TODO add comments
class Config {
  final String arg;
  final ConfigType type;
  final String? _yaml;
  final List<Commands> useInCommands;
  final String? yamlPath;
  final ArgConfig? argConfig;

  String? get yaml => _yaml ?? arg.replaceAll('-', '_');

  const Config(
      {required this.arg,
      required this.type,
      String? yaml,
      required this.useInCommands,
      this.yamlPath,
      this.argConfig})
      : _yaml = yaml;
}

//MultiOption

