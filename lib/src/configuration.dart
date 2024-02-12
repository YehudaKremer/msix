import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/context_menu_configuration.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'command_line_converter.dart';
import 'method_extensions.dart';
import 'sign_tool.dart';

/// Handles loading and validating the configuration values
class Configuration {
  final List<String> _arguments;
  final Logger _logger = GetIt.I<Logger>();
  late ArgResults _args;
  String msixAssetsPath = '';
  String? appName;
  String? publisherName;
  String? identityName;
  String? msixVersion;
  String? appDescription;
  String buildFilesFolder =
      p.join(Directory.current.path, 'build', 'windows', 'runner', 'Release');
  String? certificatePath;
  String? certificatePassword;
  String? publisher;
  String? displayName;
  String? architecture;
  String? capabilities;
  String? logoPath;
  String? executableFileName;
  List<String>? signToolOptions;
  List<String>? windowsBuildArgs;
  late Iterable<String> protocolActivation;
  String? executionAlias;
  String? fileExtension;
  String? toastActivatorCLSID;
  String? toastActivatorArguments;
  String? toastActivatorDisplayName;
  String? outputPath;
  String? outputName;
  String? publishFolderPath;
  int hoursBetweenUpdateChecks = 0;
  bool automaticBackgroundTask = false;
  bool updateBlocksActivation = false;
  bool showPrompt = false;
  bool forceUpdateFromAnyVersion = false;
  bool store = false;
  bool bundle = false;
  bool signMsix = true;
  bool installCert = true;
  bool buildWindows = true;
  bool trimLogo = true;
  bool createWithDebugBuildFiles = false;
  bool enableAtStartup = false;
  StartupTask? startupTask;
  Iterable<String>? appUriHandlerHosts;
  Iterable<String>? languages;
  String get defaultsIconsFolderPath => p.join(msixAssetsPath, 'icons');
  String get msixToolkitPath =>
      p.join(msixAssetsPath, 'MSIX-Toolkit', 'Redist.x64');
  String get msixPath =>
      p.join(outputPath ?? buildFilesFolder, '${outputName ?? appName}.msix');
  String get appInstallerPath => p.join(publishFolderPath!,
      basename(msixPath).replaceAll('.msix', '.appinstaller'));
  String pubspecYamlPath = "pubspec.yaml";
  String osMinVersion = '10.0.17763.0';
  bool isTestCertificate = false;
  ContextMenuConfiguration? contextMenuConfiguration;

  Configuration(this._arguments);

  /// Gets the configuration values from from [_arguments] or pubspec.yaml file
  Future<void> getConfigValues() async {
    _parseCliArguments(_arguments);
    await _getMsixAssetsFolderPath();
    dynamic pubspec = await _getPubspec();
    appName = pubspec['name'];
    appDescription = pubspec['description'];
    dynamic yaml = pubspec['msix_config'] ?? YamlMap();
    msixVersion =
        _args['version'] ?? yaml['msix_version'] ?? _getPubspecVersion(pubspec);
    certificatePath = _args['certificate-path'] ?? yaml['certificate_path'];
    certificatePassword = _args['certificate-password'] ??
        yaml['certificate_password']?.toString();
    outputPath = _args['output-path'] ?? yaml['output_path'];
    outputName = _args['output-name'] ?? yaml['output_name'];
    executionAlias = _args['execution-alias'] ?? yaml['execution_alias'];
    if (_args['sign-msix'].toString() == 'false' ||
        yaml['sign_msix']?.toString().toLowerCase() == 'false') {
      signMsix = false;
    }
    if (_args['install-certificate'].toString() == 'false' ||
        yaml['install_certificate']?.toString().toLowerCase() == 'false') {
      installCert = false;
    }
    if (_args['build-windows'].toString() == 'false' ||
        yaml['build_windows']?.toString().toLowerCase() == 'false') {
      buildWindows = false;
    }
    if (_args['trim-logo'].toString() == 'false' ||
        yaml['trim_logo']?.toString().toLowerCase() == 'false') {
      trimLogo = false;
    }
    store = _args.wasParsed('store') ||
        yaml['store']?.toString().toLowerCase() == 'true';
    bundle = _args.wasParsed('bundle') ||
        yaml['bundle']?.toString().toLowerCase() == 'true';
    createWithDebugBuildFiles = _args.wasParsed('debug') ||
        yaml['debug']?.toString().toLowerCase() == 'true';

    displayName = _args['display-name'] ?? yaml['display_name'];
    publisherName =
        _args['publisher-display-name'] ?? yaml['publisher_display_name'];
    publisher = _args['publisher'] ?? yaml['publisher'];
    identityName = _args['identity-name'] ?? yaml['identity_name'];
    logoPath = _args['logo-path'] ?? yaml['logo_path'];
    osMinVersion =
        _args['os-min-version'] ?? yaml['os_min_version'] ?? osMinVersion;

    final String? signToolOptionsConfig =
        (_args['signtool-options'] ?? yaml['signtool_options'])?.toString();
    if (signToolOptionsConfig != null && signToolOptionsConfig.isNotEmpty) {
      CommandLineConverter commandLineConverter = CommandLineConverter();
      signToolOptions = commandLineConverter.convert(signToolOptionsConfig);
    }

    final String? windowsBuildArgsConfig =
        (_args['windows-build-args'] ?? yaml['windows_build_args'])?.toString();
    if (windowsBuildArgsConfig != null && windowsBuildArgsConfig.isNotEmpty) {
      CommandLineConverter commandLineConverter = CommandLineConverter();
      windowsBuildArgs = commandLineConverter.convert(windowsBuildArgsConfig);
    }

    //CommandLineConverter
    protocolActivation = _getProtocolsActivation(yaml);
    fileExtension = _args['file-extension'] ?? yaml['file_extension'];
    if (fileExtension != null && !fileExtension!.startsWith('.')) {
      fileExtension = '.$fileExtension';
    }
    architecture = _args['architecture'] ?? yaml['architecture'];
    capabilities = _args['capabilities'] ?? yaml['capabilities'];
    languages = _getLanguages(yaml);
    appUriHandlerHosts = _getAppUriHandlerHosts(yaml);
    enableAtStartup = _args.wasParsed('enable-at-startup') ||
        yaml['enable_at_startup']?.toString().toLowerCase() == 'true';

    // A more advanced version of 'enable_at_startup'
    startupTask = yaml['startup_task'] != null
        ? StartupTask.fromMap(yaml['startup_task'], appName!)
        : null;

    // toast activator configurations
    dynamic toastActivatorYaml = yaml['toast_activator'] ?? YamlMap();

    toastActivatorCLSID = _args['toast-activator-clsid'] ??
        toastActivatorYaml['clsid']?.toString();
    toastActivatorArguments = _args['toast-activator-arguments'] ??
        toastActivatorYaml['arguments']?.toString() ??
        '----AppNotificationActivationServer';
    toastActivatorDisplayName = _args['toast-activator-display-name'] ??
        toastActivatorYaml['display_name']?.toString() ??
        'Toast activator';

    // app installer configurations
    dynamic installerYaml = yaml['app_installer'] ?? YamlMap();

    publishFolderPath =
        _args['publish-folder-path'] ?? installerYaml['publish_folder_path'];
    hoursBetweenUpdateChecks = int.parse(_args['hours-between-update-checks'] ??
        installerYaml['hours_between_update_checks']?.toString() ??
        '0');
    if (hoursBetweenUpdateChecks < 0) hoursBetweenUpdateChecks = 0;
    automaticBackgroundTask = _args.wasParsed('automatic-background-task') ||
        installerYaml['automatic_background_task']?.toString().toLowerCase() ==
            'true';
    updateBlocksActivation = _args.wasParsed('update-blocks-activation') ||
        installerYaml['update_blocks_activation']?.toString().toLowerCase() ==
            'true';
    showPrompt = _args.wasParsed('show-prompt') ||
        installerYaml['show_prompt']?.toString().toLowerCase() == 'true';
    forceUpdateFromAnyVersion =
        _args.wasParsed('force-update-from-any-version') ||
            installerYaml['force_update_from_any_version']
                    ?.toString()
                    .toLowerCase() ==
                'true';

    // context menu configurations
    dynamic contextMenuYaml = yaml['context_menu'];

    bool skipContextMenu = _args.wasParsed('skip-context-menu');

    contextMenuConfiguration = contextMenuYaml != null &&
            contextMenuYaml is YamlMap &&
            !skipContextMenu
        ? ContextMenuConfiguration.fromYaml(contextMenuYaml)
        : null;
  }

  /// Validate the configuration values and set default values
  Future<void> validateConfigValues() async {
    _logger.trace('validating config values');

    if (appName.isNull) {
      throw 'App name is empty, check the general \'name:\' property at pubspec.yaml';
    }
    if (appDescription.isNull) appDescription = appName;
    String cleanAppName = appName!.replaceAll('_', '');
    if (displayName.isNull) displayName = cleanAppName;
    if (identityName.isNull) {
      if (store) {
        _logger.stderr(
            'identity name is empty, check "msix_config: identity_name" at pubspec.yaml');
        throw 'you can find your store "identity_name" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Identity/Name';
      } else {
        identityName = 'com.flutter.$cleanAppName';
      }
    } else {
      if (!RegExp(r'^[a-zA-Z0-9.-]{3,50}$').hasMatch(identityName!)) {
        throw 'invalid identity name ("identity_name"): "$identityName". need to be a string between 3 and 50 characters in length that consists of alpha-numeric, period, and dash characters.';
      }
    }
    if (publisherName.isNull) {
      if (store) {
        _logger.stderr(
            'publisher display name is empty, check "msix_config: publisher_display_name" at pubspec.yaml');
        throw 'you can find your store "publisher_display_name" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Properties/PublisherDisplayName';
      } else {
        publisherName = identityName;
      }
    }
    if (signMsix == false && publisher.isNullOrEmpty) {
      _logger.stderr(
          'when sign_msix is false, you must provide the publisher value at "msix_config: publisher" in the pubspec.yaml file');
      exit(-1);
    }
    if (store && publisher.isNullOrEmpty) {
      _logger.stderr(
          'publisher is empty, check "msix_config: publisher" at pubspec.yaml');
      throw 'you can find your store "publisher" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Properties/Publisher';
    }
    if (msixVersion.isNull) msixVersion = '1.0.0.0';
    if (architecture.isNull) architecture = 'x64';

    buildFilesFolder = await _updateBuildFilesFolder();

    if (createWithDebugBuildFiles) {
      buildFilesFolder = buildFilesFolder.replaceFirst('Release', 'Debug');
    }
    _logger.trace('pack files in build folder: $buildFilesFolder');

    languages ??= ['en-us'];

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!)) {
      throw 'msix version can be only in this format: "1.0.0.0"';
    }

    if (displayName != null && displayName!.length > 256) {
      throw '"display name" is too long, it should be less than 256 characters';
    }

    if (publisherName != null && publisherName!.length > 256) {
      throw '"publisher display name" is too long, it should be less than 256 characters';
    }

    if (!certificatePath.isNull ||
        (SignTool.isCustomSignCommand(signToolOptions)) ||
        store) {
      if (!certificatePath.isNull) {
        if (!(await File(certificatePath!).exists())) {
          throw 'The file certificate not found in: $certificatePath, check "msix_config: certificate_path" at pubspec.yaml';
        }

        if (extension(certificatePath!).toLowerCase() == '.pfx' &&
            certificatePassword.isNull) {
          throw 'Certificate password is empty, check "msix_config: certificate_password" at pubspec.yaml';
        }
      }
    } else {
      // if no certificate was chosen then use test certificate
      certificatePath = p.join(msixAssetsPath, 'test_certificate.pfx');
      certificatePassword = '1234';
      isTestCertificate = true;
    }

    if (!['x64', 'arm64'].contains(architecture)) {
      throw 'Architecture can be "x64" or "arm64", check "msix_config: architecture" at pubspec.yaml';
    }

    if (contextMenuConfiguration != null) {
      if (!await File(contextMenuConfiguration!.dllPath).exists()) {
        throw 'The context menu dll file not found in: ${contextMenuConfiguration!.dllPath}, check "msix_config: context_menu: dll_path" at pubspec.yaml';
      }

      if (contextMenuConfiguration!.items.isEmpty) {
        throw 'Context menu items is empty, check "msix_config: context_menu: items" at pubspec.yaml';
      }

      for (var item in contextMenuConfiguration!.items) {
        if (item.type.isNullOrEmpty) {
          throw 'Context menu item type is empty';
        }

        if (item.commands.isEmpty) {
          throw 'Context menu item commands is empty';
        }

        if (contextMenuConfiguration!.items
                .where((element) => element.type == item.type)
                .length >
            1) {
          throw 'Found same context menu item type more than once, type must be unique for each item. Type: ${item.type}';
        }

        for (var command in item.commands) {
          if (command.id.isNullOrEmpty) {
            throw 'Context menu command id is empty';
          }

          if (command.clsid.isNullOrEmpty) {
            throw 'Context menu command clsid is empty';
          }

          if (command.customDllPath != null &&
              !await File(command.customDllPath!).exists()) {
            throw 'The context menu command custom dll file not found in: ${command.customDllPath}, check "msix_config: context_menu: items: commands: custom_dll" at pubspec.yaml';
          }

          if (command.clsid == toastActivatorCLSID) {
            throw 'Context menu command clsid cannot be the same as toast activator clsid, Clsid: ${command.clsid}';
          }

          if (item.commands
                  .where((element) => element.clsid == command.clsid)
                  .length >
              1) {
            throw 'Found same context menu command more than once in same type. Clsid: ${command.clsid}, Type: ${item.type}';
          }

          for (List<ContextMenuItemCommand> command2
              in contextMenuConfiguration!.items.map((e) => e.commands)) {
            if (command2.any((element) =>
                element.clsid == command.clsid &&
                element.customDllPath != command.customDllPath)) {
              throw 'Context menu command clsid must be unique for each class, but found duplicate.\nClsid: ${command.clsid} with different dll path: ${command.customDllPath ?? contextMenuConfiguration!.dllPath} and ${command2.firstWhere((element) => element.id == command.id).customDllPath}';
            }
          }
        }
      }
    }
  }

  /// Validate "flutter build windows" output files
  Future<void> validateWindowsBuildFiles() async {
    buildFilesFolder = await _updateBuildFilesFolder();

    _logger.trace('validating build files');

    if (!await Directory(buildFilesFolder).exists() ||
        !await Directory(buildFilesFolder)
            .list()
            .any((file) => file.path.endsWith('.exe'))) {
      throw 'Build files not found at $buildFilesFolder, first run "flutter build windows" then try again';
    }

    executableFileName = await Directory(buildFilesFolder)
        .list()
        .firstWhere((file) =>
            file.path.endsWith('.exe') &&
            !file.path.contains('PSFLauncher64.exe'))
        .then((file) => basename(file.path));
  }

  /// Declare and parse the cli arguments
  void _parseCliArguments(List<String> args) {
    _logger.trace('parsing cli arguments');

    ArgParser parser = ArgParser()
      ..addOption('certificate-password', abbr: 'p')
      ..addOption('certificate-path', abbr: 'c')
      ..addOption('version')
      ..addOption('display-name', abbr: 'd')
      ..addOption('publisher-display-name', abbr: 'u')
      ..addOption('identity-name', abbr: 'i')
      ..addOption('publisher', abbr: 'b')
      ..addOption('logo-path', abbr: 'l')
      ..addOption('os-min-version')
      ..addOption('output-path', abbr: 'o')
      ..addOption('output-name', abbr: 'n')
      ..addOption('signtool-options')
      ..addOption('windows-build-args')
      ..addOption('protocol-activation')
      ..addOption('execution-alias')
      ..addOption('file-extension', abbr: 'f')
      ..addOption('architecture', abbr: 'h')
      ..addOption('capabilities', abbr: 'e')
      ..addOption('languages')
      ..addOption('sign-msix')
      ..addOption('install-certificate')
      ..addOption('trim-logo')
      ..addOption('toast-activator-clsid')
      ..addOption('toast-activator-arguments')
      ..addOption('toast-activator-display-name')
      ..addOption('publish-folder-path')
      ..addOption('hours-between-update-checks')
      ..addOption('build-windows')
      ..addOption('app-uri-handler-hosts')
      ..addFlag('store')
      ..addFlag('bundle')
      ..addFlag('enable-at-startup')
      ..addFlag('debug')
      ..addFlag('release')
      ..addFlag('automatic-background-task')
      ..addFlag('update-blocks-activation')
      ..addFlag('show-prompt')
      ..addFlag('force-update-from-any-version')
      ..addFlag('skip-context-menu');

    // exclude -v (verbose) from the arguments
    _args = parser.parse(args.where((arg) => arg != '-v'));
  }

  Future<String> _updateBuildFilesFolder() async {
    final String buildFilesFolderStart =
        buildFilesFolder.substring(0, buildFilesFolder.lastIndexOf('runner'));
    final String buildFilesFolderArchitecture =
        p.join(buildFilesFolderStart, architecture);
    final String buildFilesFolderEnd =
        buildFilesFolder.substring(buildFilesFolder.lastIndexOf('runner'));

    if (architecture == 'arm64' &&
        !(await Directory(buildFilesFolderArchitecture).exists())) {
      _logger.stderr(
          'cannot find arm64 build folder at: $buildFilesFolderArchitecture');
      exit(-1);
    }

    if (await Directory(p.join(buildFilesFolderArchitecture, 'runner'))
        .exists()) {
      return p.join(buildFilesFolderStart, architecture, buildFilesFolderEnd);
    } else {
      return p.join(buildFilesFolderStart, buildFilesFolderEnd);
    }
  }

  Future<void> validateAppInstallerConfigValues() async {
    _logger.trace('validating app installer config values');

    if (publishFolderPath.isNullOrEmpty ||
        (!await Directory(publishFolderPath!).exists() &&
            !await Directory(publishFolderPath =
                    '${Directory.current.path}\\${publishFolderPath!}')
                .exists())) {
      _logger.stderr(
          'publish folder path is not exists, check "app_installer: publish_folder_path" at pubspec.yaml'
              .red);
      exit(-1);
    } else {
      publishFolderPath = Uri.decodeFull(publishFolderPath!);
    }
  }

  /// Get the assets folder path from the .packages file
  Future<void> _getMsixAssetsFolderPath() async {
    PackageConfig? packagesConfig = await findPackageConfig(Directory.current);
    if (packagesConfig == null) {
      throw 'Failed to locate or read package config.';
    }

    Package? msixPackage = packagesConfig['msix'];

    // Locate package config from script file directory
    if (msixPackage == null) {
      final scriptFile = File.fromUri(Platform.script);
      packagesConfig = await findPackageConfig(scriptFile.parent);
      msixPackage = packagesConfig?['msix'];
    }

    if (msixPackage == null) {
      throw 'Failed to locate msix assets path.';
    }

    String path =
        '${msixPackage.packageUriRoot.toString().replaceAll('file:///', '')}assets';

    msixAssetsPath = Uri.decodeFull(path);
  }

  /// Get pubspec.yaml content
  dynamic _getPubspec() async {
    String pubspecString = await File(pubspecYamlPath).readAsString();
    dynamic pubspec = loadYaml(pubspecString);
    return pubspec;
  }

  String? _getPubspecVersion(dynamic yaml) {
    // Existing behavior is to put null if no version, so matching
    if (yaml['version'] == null) return null;
    try {
      final Version pubspecVersion = Version.parse(yaml['version']);
      return [
        pubspecVersion.major,
        pubspecVersion.minor,
        pubspecVersion.patch,
        0
      ].join('.');
    } on FormatException {
      _logger.stderr(
        'Warning: Could not parse Pubspec version. No version provided.',
      );
      return null;
    }
  }

  /// Get the languages list
  Iterable<String>? _getLanguages(dynamic config) =>
      ((_args['languages'] ?? config['languages']) as String?)
          ?.split(',')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty);

  /// Get the app uri handler hosts list
  Iterable<String>? _getAppUriHandlerHosts(dynamic config) =>
      ((_args['app-uri-handler-hosts'] ?? config['app_uri_handler_hosts'])
              as String?)
          ?.split(',')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty);

  /// Get the protocol activation list
  Iterable<String> _getProtocolsActivation(dynamic config) =>
      ((_args['protocol-activation'] ?? config['protocol_activation'])
              as String?)
          ?.split(',')
          .map((protocol) => protocol
              .trim()
              .toLowerCase()
              .replaceAll('://', '')
              .replaceAll(':/', '')
              .replaceAll(':', ''))
          .where((protocol) => protocol.isNotEmpty) ??
      [];
}

/// A more advanced version of 'enable_at_startup'.
class StartupTask {
  /// Identifier to enable / disable programmatically
  final String taskId;

  /// If true, then autostart is enabled by default
  final bool enabled;

  /// Parameters separated by space.
  /// This is useful to detect if the app was started automatically.
  final String? parameters;

  StartupTask({
    required this.taskId,
    required this.enabled,
    required this.parameters,
  });

  factory StartupTask.fromMap(Map map, String appName) {
    return StartupTask(
      taskId: map['task_id'] ?? appName.replaceAll('_', ''),
      enabled: map['enabled'] ?? true,
      parameters: map['parameters'],
    );
  }
}
