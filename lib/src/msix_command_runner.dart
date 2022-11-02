import 'package:args/command_runner.dart';

var msixCommandRunner = CommandRunner(
    "msix", // TODO: check `valueHelp` and more in the addOption/flag method
    "A command line tool for creating MSIX installers from your Flutter app.")
  ..argParser.addOption('certificate-password',
      abbr: 'p', help: 'Password for the certificate.')
  ..argParser.addOption('certificate-path',
      abbr: 'c',
      help: 'Path to the certificate content to place in the store.',
      valueHelp: 'C:\\certs\\signcert.pfx')
  ..argParser.addOption('version',
      help: 'The version number of the package, in a.b.c.d format.',
      valueHelp: '1.0.0.0')
  ..argParser.addOption('display-name',
      abbr: 'd',
      help: 'A friendly name for the publisher that can be displayed to users.')
  ..argParser.addOption('publisher-display-name',
      abbr: 'u',
      help: 'A friendly name for the publisher that can be displayed to users.')
  ..argParser.addOption('identity-name',
      abbr: 'i',
      help: 'Defines the unique identifier for the app.',
      valueHelp: 'company.suite.flutterapp')
  ..argParser.addOption('publisher',
      abbr: 'b',
      help:
          'The Subject value in the certificate. Required only if publish to the store, or if the Publisher will not found automatically by this package.',
      valueHelp: 'CN=BF212345-5644-46DF-8668-014043C1B138')
  ..argParser.addOption('logo-path',
      abbr: 'l',
      help:
          'Path to an image file for use as the app icon (size recommended at least 400x400px).',
      valueHelp: 'C:\\images\\logo.png')
  ..argParser.addOption('output-path',
      abbr: 'o',
      help: 'The directory where the output MSIX file should be stored.',
      valueHelp: 'C:\\src\\some\\folder')
  ..argParser.addOption('output-name',
      abbr: 'n',
      help: 'The filename that should be given to the created MSIX file.',
      valueHelp: 'flutterApp_name')
  ..argParser.addOption('signtool-options',
      help:
          'Options to be provided to the signtool for app signing (see below.)',
      valueHelp: '/v /fd SHA256 /f C:/Users/me/Desktop/my.cer')
  ..argParser.addOption('protocol-activation',
      help: 'Protocols activation that will activate the app.',
      valueHelp: 'http,https')
  ..argParser.addOption('execution-alias',
      help: 'Execution alias command (cmd) that will activate the app.',
      valueHelp: 'myapp')
  ..argParser.addOption('file-extension',
      abbr: 'f',
      help: 'File extensions that the app may be registered to open.',
      valueHelp: '.picture, .image')
  // TODO change 'h', getting error: 'Abbreviation "h" is already used by "help"'
  ..argParser.addOption('architecture',
      help:
          'Describes the architecture of the code in the package, x64 or x86, x64 is default.',
      valueHelp: 'x64 or x86') // TODO: i deleted "abbr: 'h'"!!!

  ..argParser.addSeparator('Global flags:')
  ..argParser.addOption('capabilities',
      abbr: 'e',
      help: 'List of the capabilities the app requires.',
      valueHelp:
          'internetClient,location,microphone,webcam') // TODO: try use `addMultiOption()`
  ..argParser.addOption('languages',
      help: 'Declares the language resources contained in the package.',
      valueHelp: 'en-us, ja-jp')
  ..argParser.addOption('toast-activator-clsid',
      help: 'The UUID CLSID.', valueHelp: 'your-guid-C173E6ADF0C3', hide: true)
  ..argParser.addOption('toast-activator-arguments',
      help: 'Arguments for the toast notifications.',
      valueHelp: '----AppNotificationActivationServer',
      hide: true)
  ..argParser.addOption('toast-activator-display-name',
      help: 'Display name for the toast notifications.', hide: true)
  ..argParser.addOption('publish-folder-path',
      help:
          'A path to publish folder, where the msix versions and the .appinstaller file will be saved.',
      valueHelp: 'c:\\path\\to\\myPublishFolder')
  ..argParser.addOption('hours-between-update-checks',
      help:
          'Defines the minimal time gap between update checks, when the user open the app. default is 0 (will check for update every time the app opened)',
      valueHelp: '2')
  ..argParser.addFlag('no-build-windows',
      help: 'Don\'t run the build command flutter build windows.',
      negatable: false)
  ..argParser.addOption('app-uri-handler-hosts',
      help: 'Enable apps for websites using app URI handlers app.',
      valueHelp: 'test.com, test2.info')
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
  ..argParser.addFlag('no-sign-msix',
      help: 'Don\'t sign the msix file.', negatable: false)
  ..argParser.addFlag('no-install-certificate',
      help: 'Don\'t try to install the certificate.', negatable: false)
  ..argParser.addFlag('no-trim-logo',
      help: 'Don\'t trim the logo image.', negatable: false)
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
