import 'package:msix/src/method_extensions.dart';
import 'package:yaml/yaml.dart';

class ContextMenuConfiguration {
  final String dllPath;
  List<ContextMenuItem> items;

  ContextMenuConfiguration({required this.dllPath, required this.items});

  List<ContextMenuComSurrogateServer> get comSurrogateServers {
    return items
        .map((e) => e.commands)
        .expand((e) => e)
        .map((e) {
          return ContextMenuComSurrogateServer(
              clsid: e.clsid, dllPath: e.customDllPath ?? dllPath);
        })
        .toList()
        .unique((element) => element.clsid);
  }

  factory ContextMenuConfiguration.fromYaml(YamlMap json) {
    return ContextMenuConfiguration(
        dllPath: json['dll_path'],
        items: (json['items'] as YamlList)
            .map((e) => ContextMenuItem.fromYaml(e))
            .toList());
  }

  @override
  String toString() {
    return 'ContextMenuConfiguration{dllPath: $dllPath, items: $items}';
  }
}

class ContextMenuItem {
  String type;
  List<ContextMenuItemCommand> commands;

  ContextMenuItem({required this.type, required this.commands});

  factory ContextMenuItem.fromYaml(YamlMap json) {
    return ContextMenuItem(
        type: json['type'],
        commands: (json['commands'] as YamlList)
            .map((e) => ContextMenuItemCommand.fromYaml(e))
            .toList());
  }

  @override
  String toString() {
    return 'ContextMenuItem{type: $type, commands: $commands}';
  }
}

class ContextMenuItemCommand {
  final String id;
  final String clsid;
  final String? customDllPath;

  ContextMenuItemCommand(
      {required this.id, required this.clsid, this.customDllPath});

  factory ContextMenuItemCommand.fromYaml(YamlMap json) {
    return ContextMenuItemCommand(
        id: json['id'],
        clsid: json['clsid'],
        customDllPath: json['custom_dll']);
  }

  @override
  String toString() {
    return 'ContextMenuItemCommand{id: $id, clsid: $clsid, customDllPath: $customDllPath}';
  }
}

class ContextMenuComSurrogateServer {
  final String clsid;
  final String dllPath;

  ContextMenuComSurrogateServer({required this.clsid, required this.dllPath});

  @override
  String toString() {
    return 'ContextMenuComSurrogateServer{clsid: $clsid, dllPath: $dllPath}';
  }
}
