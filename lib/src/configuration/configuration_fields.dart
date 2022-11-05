import 'package:msix/src/configuration/config.dart';

import 'arg_config.dart';
import 'commands.dart';
import 'yaml_paths.dart';

const List<Config> rootFields = [
  Config(name: 'name', useInCommands: [Commands.global]),
  Config(name: 'description', useInCommands: [Commands.global]),
  Config(name: 'version', useInCommands: [Commands.global])
];
const List<Config> msixFields = [
  Config(
      name: 'version',
      useInCommands: [Commands.build, Commands.create, Commands.publish],
      yamlPath: YamlPaths.msixConfig,
      argConfig: ArgConfig(
        help: 'The version number of the package, in a.b.c.d format.',
        valueHelp: '1.0.0.0',
      )),
  Config(
      name: 'certificate_path',
      useInCommands: [Commands.build, Commands.create, Commands.publish],
      yamlPath: YamlPaths.msixConfig,
      argConfig: ArgConfig(
        abbr: 'c',
        help: 'Path to the certificate content to place in the store.',
        valueHelp: 'C:\\certs\\cert.pfx',
      )),
  Config(
      name: 'certificate_password',
      useInCommands: [Commands.build, Commands.create, Commands.publish],
      yamlPath: YamlPaths.msixConfig,
      argConfig: ArgConfig(
        abbr: 'p',
        help: 'Password for the certificate.',
      )),
  Config(
    name: 'output_path',
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'o',
        help: 'The directory where the output MSIX file should be stored.',
        valueHelp: 'C:\\src\\some\\folder'),
  ),
  Config(
    name: 'output_name',
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'n',
        help: 'The filename that should be given to the created MSIX file.',
        valueHelp: 'flutterApp_name'),
  ),
  'execution_alias',
  'no_sign_msix',
  'no_install_certificate',
  'no_build_windows',
  'no_trim_logo',
  'store',
  'debug',
  'display_name',
  'publisher_display_name',
  'publisher',
  'identity_name',
  'logo_path',
  'signtool_options',
  'protocol_activation',
  'file_extension',
  'architecture',
  'capabilities',
  'languages',
  'app_uri_handler_hosts',
  'enable_at_startup'
];
const List<Config> appInstallerFields = [
  'publish_folder_path',
  'hours_between_update_checks',
  'automatic_background_task',
  'update_blocks_activation',
  'show_prompt',
  'force_update_from_any_version'
];
const List<Config> toastActivatorFields = [
  'clsid',
  'arguments',
  'display_name'
];
