import 'dart:collection';
import 'dart:io';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'extensions.dart';

class Configuration {
  List<String> _arguments;
  Logger _logger;
  late ArgResults _args;
  String msixAssetsPath = '';
  String? appName;
  String? publisherName;
  String? identityName;
  String? msixVersion;
  String? appDescription;
  String buildFilesFolder =
      '${Directory.current.path}/build/windows/runner/Release';
  String? certificatePath;
  String? certificatePassword;
  String? publisher;
  String? displayName;
  String? architecture;
  String? capabilities;
  String? logoPath;
  String? executableFileName;
  List<String>? signToolOptions;
  String? protocolActivation;
  String? fileExtension;
  String? toastActivatorCLSID;
  String? toastActivatorArguments;
  String? toastActivatorDisplayName;
  String? outputPath;
  String? outputName;
  String? publishFolderPath;
  String? appInstallerFolderPath;
  int hoursBetweenUpdateChecks = 0;
  bool automaticBackgroundTask = true;
  bool updateBlocksActivation = true;
  bool showPrompt = true;
  bool forceUpdateFromAnyVersion = false;
  bool store = false;
  bool installCert = true;
  bool addExecutionAlias = false;
  bool createWithDebugBuildFiles = false;
  Iterable<String>? languages;
  String get defaultsIconsFolderPath => '$msixAssetsPath/icons';
  String get vcLibsFolderPath => '$msixAssetsPath/VCLibs';
  String get msixToolkitPath => '$msixAssetsPath/MSIX-Toolkit';
  String get iconsGeneratorPath => '$msixAssetsPath/IconsGenerator';
  String pubspecYamlPath = "pubspec.yaml";

  Configuration(this._arguments, this._logger);

  /// Gets the configuration values from pubspec.yaml file and from [_arguments]
  Future<void> getConfigValues() async {
    _parseCliArguments(_arguments);
    await _getMsixAssetsFolderPath();
    var pubspec = await _getPubspec();
    appName = pubspec['name'];
    appDescription = pubspec['description'];
    var yaml = pubspec['msix_config'] ?? YamlMap();
    msixVersion = _args['version'] ?? yaml['msix_version'];
    certificatePath = _args['certificate-path'] ?? yaml['certificate_path'];
    certificatePassword = _args['certificate-password'] ??
        yaml['certificate_password']?.toString();
    outputPath = _args['output-path'] ?? yaml['output_path'];
    outputName = _args['output-name'] ?? yaml['output_name'];
    addExecutionAlias = _args.wasParsed('add-execution-alias') ||
        yaml['add_execution_alias']?.toLowerCase() == 'true';
    installCert = _args['install-certificate'] != 'false' &&
        yaml['install_certificate'] != 'false';
    store = _args.wasParsed('store') ||
        yaml['store']?.toString().toLowerCase() == 'true';
    createWithDebugBuildFiles = _args.wasParsed('debug') ||
        yaml['debug']?.toString().toLowerCase() == 'true';
    if (createWithDebugBuildFiles)
      buildFilesFolder = buildFilesFolder.replaceFirst('Release', 'Debug');
    displayName = _args['display-name'] ?? yaml['display_name'];
    publisherName =
        _args['publisher-display-name'] ?? yaml['publisher_display_name'];
    publisher = _args['publisher'] ?? yaml['publisher'];
    identityName = _args['identity-name'] ?? yaml['identity_name'];
    logoPath = _args['logo-path'] ?? yaml['logo_path'];
    signToolOptions = (_args['signtool-options'] ?? yaml['signtool_options'])
        ?.toString()
        .split(' ')
        .where((o) => o.trim().length > 0)
        .toList();
    protocolActivation =
        (_args['protocol-activation'] ?? yaml['protocol_activation'])
            ?.toString()
            .replaceAll(':', '');
    fileExtension = _args['file-extension'] ?? yaml['file_extension'];
    if (fileExtension != null && !fileExtension!.startsWith('.')) {
      fileExtension = '.$fileExtension';
    }
    architecture = _args['architecture'] ?? yaml['architecture'];
    capabilities = _args['capabilities'] ?? yaml['capabilities'];
    languages = _getLanguages(yaml);

    // toast activator configurations
    var toastActivatorYaml = yaml['toast_activator'] ?? YamlMap();

    toastActivatorCLSID =
        _args['toast-activator-clsid'] ?? toastActivatorYaml['clsid'];
    toastActivatorArguments = _args['toast-activator-arguments'] ??
        toastActivatorYaml['arguments'] ??
        '----AppNotificationActivationServer';
    toastActivatorDisplayName = _args['toast-activator-display-name'] ??
        toastActivatorYaml['display_name'] ??
        'Toast activator';

    // app installer configurations
    var installerYaml = yaml['app_installer'] ?? YamlMap();

    publishFolderPath =
        _args['publish-folder-path'] ?? installerYaml['publish_folder_path'];
    appInstallerFolderPath = _args['app-installer-folder-path'] ??
        installerYaml['app_installer_folder_path'];
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
  }

  /// Validate the configuration values and set default values
  Future<void> validateConfigValues() async {
    _logger.trace('validating config values');

    if (appName.isNull) {
      throw 'App name is empty, check the general \'name:\' property at pubspec.yaml';
    }
    if (appDescription.isNull) appDescription = appName;
    if (displayName.isNull) displayName = _cleanAppName();
    if (identityName.isNull) {
      if (store) {
        _logger.stderr(
            'identity name is empty, check "msix_config: identity_name" at pubspec.yaml');
        throw 'you can find your store "identity_name" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Identity/Name';
      } else {
        identityName = 'com.flutter.${_cleanAppName()}';
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
    if (store && publisher.isNullOrEmpty) {
      _logger.stderr(
          'publisher is empty, check "msix_config: publisher" at pubspec.yaml');
      throw 'you can find your store "publisher" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Properties/Publisher';
    }
    if (msixVersion.isNull) msixVersion = '1.0.0.0';
    if (architecture.isNull) architecture = 'x64';
    if (capabilities.isNull)
      capabilities = 'internetClient,location,microphone,webcam';
    if (languages == null) languages = ['en-us'];

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!)) {
      throw 'msix version can be only in this format: "1.0.0.0"';
    }

    if (displayName != null && displayName!.length > 256) {
      throw '"display name" is too long, it should be less than 256 characters';
    }

    if (publisherName != null && publisherName!.length > 256) {
      throw '"publisher display name" is too long, it should be less than 256 characters';
    }

    if (!certificatePath.isNull || signToolOptions != null || store) {
      if (!certificatePath.isNull) {
        if (!(await File(certificatePath!).exists())) {
          throw 'The file certificate not found in: $certificatePath, check "msix_config: certificate_path" at pubspec.yaml';
        }

        if (extension(certificatePath!) == '.pfx' &&
            certificatePassword.isNull) {
          throw 'Certificate password is empty, check "msix_config: certificate_password" at pubspec.yaml';
        }
      }
    } else {
      /// If no certificate was chosen then use test certificate
      certificatePath = '$msixAssetsPath/test_certificate.pfx';
      certificatePassword = '1234';
    }

    if (!['x86', 'x64'].contains(architecture)) {
      throw 'Architecture can be "x86" or "x64", check "msix_config: architecture" at pubspec.yaml';
    }
  }

  Future<void> validateBuildFiles() async {
    _logger.trace('validating build files');

    if (!await Directory(buildFilesFolder).exists() ||
        !await Directory(buildFilesFolder)
            .list()
            .any((file) => file.path.endsWith('.exe'))) {
      throw 'Build files not found at $buildFilesFolder, first run "flutter build windows" then try again';
    }

    executableFileName = await Directory(buildFilesFolder)
        .list()
        .firstWhere(
            (file) =>
                file.path.endsWith('.exe') &&
                !file.path.contains('PSFLauncher64.exe'),
            orElse: () => Directory(buildFilesFolder).listSync().first)
        .then((file) => basename(file.path));
  }

  bool haveLogoPath() => !logoPath.isNull;

  /// parse the cli arguments
  void _parseCliArguments(List<String> args) {
    _logger.trace('parsing cli arguments');

    var parser = ArgParser()
      ..addOption('certificate-password', abbr: 'p')
      ..addOption('certificate-path', abbr: 'c')
      ..addOption('version')
      ..addOption('display-name', abbr: 'd')
      ..addOption('publisher-display-name', abbr: 'u')
      ..addOption('identity-name', abbr: 'i')
      ..addOption('publisher', abbr: 'b')
      ..addOption('logo-path', abbr: 'l')
      ..addOption('output-path', abbr: 'o')
      ..addOption('output-name', abbr: 'n')
      ..addOption('signtool-options')
      ..addOption('protocol-activation')
      ..addOption('file-extension', abbr: 'f')
      ..addOption('architecture', abbr: 'h')
      ..addOption('capabilities', abbr: 'e')
      ..addOption('languages')
      ..addOption('install-certificate')
      ..addOption('toast-activator-clsid')
      ..addOption('toast-activator-arguments')
      ..addOption('toast-activator-display-name')
      ..addOption('publish-folder-path')
      ..addOption('app-installer-folder-path')
      ..addOption('hours-between-update-checks')
      ..addFlag('store')
      ..addFlag('add-execution-alias')
      ..addFlag('debug')
      ..addFlag('release')
      ..addFlag('automatic-background-task')
      ..addFlag('update-blocks-activation')
      ..addFlag('show-prompt')
      ..addFlag('force-update-from-any-version');

    /// exclude -v (verbose) from the arguments
    _args = parser.parse(args.where((arg) => arg != '-v'));
  }

  Future<void> validateAppInstallerConfigValues() async {
    _logger.trace('validating app installer config values');

    if (publishFolderPath.isNullOrEmpty ||
        !await Directory(publishFolderPath!).exists()) {
      _logger.stderr(
          '${Ansi(true).red}publish folder path is not exists, check "app_installer: publish_folder_path" at pubspec.yaml${Ansi(true).none}');
      exit(-1);
    }

    if (appInstallerFolderPath.isNullOrEmpty) {
      appInstallerFolderPath = publishFolderPath;
    } else if (Uri.tryParse(appInstallerFolderPath!) == null) {
      _logger.stderr(
          '${Ansi(true).red}installer path is a valid url, check "app_installer: app_installer_folder_path" at pubspec.yaml${Ansi(true).none}');
      exit(-1);
    } else {
      appInstallerFolderPath = Uri.decodeFull(appInstallerFolderPath!);
    }
  }

  /// Get the assets folder path from the .packages file
  Future<void> _getMsixAssetsFolderPath() async {
    var packagesConfig = await findPackageConfig(Directory.current);
    if (packagesConfig == null) {
      throw 'Failed to locate or read package config.';
    }

    var msixPackage =
        packagesConfig.packages.firstWhere((package) => package.name == "msix");
    var path =
        msixPackage.packageUriRoot.toString().replaceAll('file:///', '') +
            'assets';

    msixAssetsPath = Uri.decodeFull(path);
  }

  /// Get pubspec.yaml content
  dynamic _getPubspec() async {
    var pubspecString = await File(pubspecYamlPath).readAsString();
    var pubspec = loadYaml(pubspecString);
    return pubspec;
  }

  Iterable<String>? _getLanguages(dynamic config) =>
      ((_args['languages'] ?? config['languages']) as String?)
          ?.split(',')
          .map((e) => e.trim())
          .where((element) => element.length > 0);

  String _cleanAppName() => appName!.replaceAll('_', '');
}
