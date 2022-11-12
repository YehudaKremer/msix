import 'package:msix/src/configuration/config.dart';
import 'package:msix/src/configuration/config_type.dart';

import 'arg_config.dart';
import 'commands.dart';
import 'yaml_paths.dart';

const List<Config> configFields = [
  Config(arg: 'name', type: ConfigType.flag, useInCommands: [Commands.global]),
  Config(
      arg: 'description',
      type: ConfigType.option,
      useInCommands: [Commands.global]),
  Config(
      arg: 'version',
      type: ConfigType.option,
      useInCommands: [Commands.build, Commands.create, Commands.publish],
      yamlPath: YamlPaths.msixConfig,
      argConfig: ArgConfig(
        help: 'The version number of the package, in a.b.c.d format.',
        valueHelp: '1.0.0.0',
      )),
  Config(
      arg: 'certificate-path',
      type: ConfigType.option,
      useInCommands: [Commands.build, Commands.create, Commands.publish],
      yamlPath: YamlPaths.msixConfig,
      argConfig: ArgConfig(
        abbr: 'c',
        help: 'Path to the certificate content to place in the store.',
        valueHelp: 'C:\\certs\\cert.pfx',
      )),
  Config(
      arg: 'certificate-password',
      type: ConfigType.option,
      useInCommands: [Commands.build, Commands.create, Commands.publish],
      yamlPath: YamlPaths.msixConfig,
      argConfig: ArgConfig(
        abbr: 'p',
        help: 'Password for the certificate.',
      )),
  Config(
    arg: 'output-path',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'o',
        help: 'The directory where the output MSIX file should be stored.',
        valueHelp: 'C:\\src\\some\\folder'),
  ),
  Config(
    arg: 'output-name',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'n',
        help: 'The filename that should be given to the created MSIX file.',
        valueHelp: 'flutterApp_name'),
  ),
  Config(
    arg: 'execution-alias',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'File extensions that the app may be registered to open.',
        valueHelp: '.picture, .image'),
  ),
  Config(
    arg: 'no-sign-msix',
    type: ConfigType.flag,
    useInCommands: [Commands.pack, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(help: 'Don\'t sign the msix file.', negatable: false),
  ),
  Config(
    arg: 'no-install-certificate',
    type: ConfigType.flag,
    useInCommands: [Commands.pack, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Don\'t try to install the certificate.', negatable: false),
  ),
  Config(
    arg: 'no-build-windows',
    type: ConfigType.flag,
    useInCommands: [Commands.global],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Don\'t run the build command flutter build windows.',
        negatable: false),
  ),
  Config(
    arg: 'no-trim-logo',
    type: ConfigType.flag,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(help: 'Don\'t trim the logo image.', negatable: false),
  ),
  Config(
    arg: 'store',
    type: ConfigType.flag,
    useInCommands: [Commands.build, Commands.pack, Commands.create],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Generate a MSIX file for publishing to the Microsoft Store.'),
  ),
  Config(
    arg: 'debug',
    type: ConfigType.flag,
    useInCommands: [Commands.global],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help:
            'Create MSIX from the debug build files (\\build\\windows\\runner\\debug), release is the default.'),
  ),
  Config(
    arg: 'display-name',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'd',
        help:
            'A friendly name for the publisher that can be displayed to users.'),
  ),
  Config(
    arg: 'publisher-display-name',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'u',
        help:
            'A friendly name for the publisher that can be displayed to users.'),
  ),
  Config(
    arg: 'publisher',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'b',
        help:
            'The Subject value in the certificate. Required only if publish to the store, or if the Publisher will not found automatically by this package.'),
  ),
  Config(
    arg: 'identity-name',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'i',
        help: 'Defines the unique identifier for the app.',
        valueHelp: 'company.suite.flutterapp'),
  ),
  Config(
    arg: 'logo-path',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'l',
        help:
            'Path to an image file for use as the app icon (size recommended at least 400x400px).',
        valueHelp: 'C:\\images\\logo.png'),
  ),
  Config(
    arg: 'signtool-options',
    type: ConfigType.option,
    useInCommands: [Commands.global],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help:
            'Options to be provided to the signtool for app signing (see below.)',
        valueHelp: '/v /fd SHA256 /f C:/Users/me/Desktop/my.cer'),
  ),
  Config(
    arg: 'protocol-activation',
    type: ConfigType.multiOption,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Protocols activation that will activate the app.',
        valueHelp: 'http, https'),
  ),
  Config(
    arg: 'file-extension',
    type: ConfigType.multiOption,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'f',
        help: 'File extensions that the app may be registered to open.',
        valueHelp: '.picture, .image'),
  ),
  Config(
    arg: 'architecture',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Describes the architecture of the code in the package.',
        allowed: ['x64', 'x86']),
  ),
  Config(
    arg: 'capabilities',
    type: ConfigType.multiOption,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        abbr: 'e',
        help: 'List of the capabilities the app requires.',
        valueHelp: 'internetClient,location,microphone,webcam'),
  ),
  Config(
    arg: 'languages',
    type: ConfigType.multiOption,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Declares the language resources contained in the package.',
        valueHelp: 'en-us, ja-jp'),
  ),
  Config(
    arg: 'app-uri-handler-hosts',
    type: ConfigType.multiOption,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(
        help: 'Enable apps for websites using app URI handlers app.',
        valueHelp: 'test.com, test2.info'),
  ),
  Config(
    arg: 'enable-at-startup',
    type: ConfigType.flag,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.msixConfig,
    argConfig: ArgConfig(help: 'App start at startup or user log-in.'),
  ),
  Config(
    arg: 'publish-folder-path',
    type: ConfigType.option,
    useInCommands: [Commands.publish],
    yamlPath: YamlPaths.appInstaller,
    argConfig: ArgConfig(
        help:
            'A path to publish folder, where the msix versions and the .appinstaller file will be saved.',
        valueHelp: 'c:\\path\\to\\myPublishFolder'),
  ),
  Config(
    arg: 'hours-between-update-checks',
    type: ConfigType.option,
    useInCommands: [Commands.publish],
    yamlPath: YamlPaths.appInstaller,
    argConfig: ArgConfig(
        help:
            'Defines the minimal time gap between update checks, when the user open the app. default is 0 (will check for update every time the app opened)',
        valueHelp: '2'),
  ),
  Config(
    arg: 'automatic-background-task',
    type: ConfigType.flag,
    useInCommands: [Commands.publish],
    yamlPath: YamlPaths.appInstaller,
    argConfig: ArgConfig(
        help:
            'Checks for updates in the background every 8 hours independently of whether the user launched the app.'),
  ),
  Config(
    arg: 'update-blocks-activation',
    type: ConfigType.flag,
    useInCommands: [Commands.publish],
    yamlPath: YamlPaths.appInstaller,
    argConfig: ArgConfig(
        help: 'Defines the experience when an app update is checked for.'),
  ),
  Config(
    arg: 'show-prompt',
    type: ConfigType.flag,
    useInCommands: [Commands.publish],
    yamlPath: YamlPaths.appInstaller,
    argConfig: ArgConfig(
        help:
            'Defines if a window is displayed when updates are being installed, and when updates are being checked for.'),
  ),
  Config(
    arg: 'force-update-from-any-version',
    type: ConfigType.flag,
    useInCommands: [Commands.publish],
    yamlPath: YamlPaths.appInstaller,
    argConfig: ArgConfig(
        help:
            'Allows the app to update from version x to version x++ or to downgrade from version x to version x--.'),
  ),
  Config(
    arg: 'toast-activator-clsid',
    yaml: 'clsid',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.toastActivator,
    argConfig:
        ArgConfig(help: 'The UUID CLSID.', valueHelp: 'your-guid-C173E6ADF0C3'),
  ),
  Config(
    arg: 'toast-activator-arguments',
    yaml: 'arguments',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.toastActivator,
    argConfig: ArgConfig(
        help: 'Arguments for the toast notifications.',
        valueHelp: '----AppNotificationActivationServer'),
  ),
  Config(
    arg: 'toast-activator-display-name',
    yaml: 'display_name',
    type: ConfigType.option,
    useInCommands: [Commands.build, Commands.create, Commands.publish],
    yamlPath: YamlPaths.toastActivator,
    argConfig: ArgConfig(help: 'Display name for the toast notifications.'),
  ),
];
