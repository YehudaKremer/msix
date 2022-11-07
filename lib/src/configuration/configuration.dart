import 'dart:io';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/configuration/commands.dart';
import 'package:msix/src/configuration/config.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import '../command_line_converter.dart';
import '../method_extensions.dart';
import 'configuration_fields.dart';

/// Handles loading and validating the configuration values
class Configuration {
  final Logger _logger = GetIt.I<Logger>();
  late final ArgResults _args;
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
  late List<String> capabilities;
  String? logoPath;
  String? executableFileName;
  late List<String> signToolOptions;
  late List<String> protocolsActivation;
  String? executionAlias;
  late List<String> fileExtensions;
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
  bool noSignMsix = false;
  bool noInstallCert = false;
  bool noBuildWindows = false;
  bool noTrimLogo = false;
  bool createWithDebugBuildFiles = false;
  bool enableAtStartup = false;
  late List<String> appUriHandlerHosts;
  late List<String> languages;
  String get defaultsIconsFolderPath => '$msixAssetsPath/icons';
  String get msixToolkitPath => '$msixAssetsPath/MSIX-Toolkit';
  String get msixPath =>
      '${outputPath ?? buildFilesFolder}/${outputName ?? appName}.msix';
  String get appInstallerPath =>
      '$publishFolderPath/${basename(msixPath).replaceAll('.msix', '.appinstaller')}';
  String pubspecYamlPath = "pubspec.yaml";
  String osMinVersion = '10.0.17763.0';

  Configuration(this._args);

  List<Config> getConfigArgs() {
    List<Config> configs = rootFields
        .map((field) => Config(arg: field, useInCommands: [Commands.global]))
        .toList();

    configs.addAll(msixFields
        .map((field) => Config(arg: field, useInCommands: [Commands.global])));

    return configs;
  }

  /// Gets the configuration values from [_args] or from pubspec.yaml file
  Future<void> getConfigValues() async {
    await _getMsixAssetsFolderPath();
    dynamic pubspec = await _getPubspec();
    appName = pubspec['name'];
    appDescription = pubspec['description'];
    dynamic yaml = pubspec['msix_config'] ?? YamlMap();
    msixVersion =
        _args['version'] ?? yaml['version'] ?? _getPubspecVersion(pubspec);
    certificatePath = _args['certificate-path'] ?? yaml['certificate_path'];
    certificatePassword = _args['certificate-password'] ??
        yaml['certificate_password']?.toString();
    outputPath = _args['output-path'] ?? yaml['output_path'];
    outputName = _args['output-name'] ?? yaml['output_name'];
    executionAlias = _args['execution-alias'] ?? yaml['execution_alias'];
    noSignMsix = _args.wasParsed('no-sign-msix') ||
        yaml['no_sign_msix']?.toString().toLowerCase() == 'true';
    noInstallCert = _args.wasParsed('no-install-certificate') ||
        yaml['no_install_certificate']?.toString().toLowerCase() == 'true';
    noBuildWindows = _args.wasParsed('no-build-windows') ||
        yaml['no_build_windows']?.toString().toLowerCase() == 'true';
    noTrimLogo = _args.wasParsed('no-trim-logo') ||
        yaml['no_trim_logo']?.toString().toLowerCase() == 'true';
    store = _args.wasParsed('store') ||
        yaml['store']?.toString().toLowerCase() == 'true';
    createWithDebugBuildFiles = _args.wasParsed('debug') ||
        yaml['debug']?.toString().toLowerCase() == 'true';
    if (createWithDebugBuildFiles) {
      buildFilesFolder = buildFilesFolder.replaceFirst('Release', 'Debug');
    }
    displayName = _args['display-name'] ?? yaml['display_name'];
    publisherName =
        _args['publisher-display-name'] ?? yaml['publisher_display_name'];
    publisher = _args['publisher'] ?? yaml['publisher'];
    identityName = _args['identity-name'] ?? yaml['identity_name'];
    logoPath = _args['logo-path'] ?? yaml['logo_path'];
    String? signToolOptionsArgs =
        _args['signtool-options'] ?? yaml['signtool_options']?.toString();
    if (signToolOptionsArgs != null && signToolOptionsArgs.isNotEmpty) {
      CommandLineConverter commandLineConverter = CommandLineConverter();
      signToolOptions = commandLineConverter.convert(signToolOptionsArgs);
    }

    protocolsActivation = _getProtocolsActivation(yaml);
    fileExtensions = _args['file-extension'] ??
        _getMultiConfigValues(yaml, 'file_extension');
    fileExtensions = fileExtensions
        .map((fileExtension) =>
            fileExtension.startsWith('.') ? fileExtension : '.$fileExtension')
        .toList();

    architecture = _args['architecture'] ?? yaml['architecture'];
    capabilities =
        _args['capabilities'] ?? _getMultiConfigValues(yaml, 'capabilities');
    languages = _args['languages'] ?? _getMultiConfigValues(yaml, 'languages');
    appUriHandlerHosts = _args['app-uri-handler-hosts'] ??
        _getMultiConfigValues(yaml, 'app_uri_handler_hosts');
    enableAtStartup = _args.wasParsed('enable-at-startup') ||
        yaml['enable_at_startup']?.toString().toLowerCase() == 'true';

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
  }

//TODO: split to two files
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
    if (noSignMsix && publisher.isNullOrEmpty) {
      _logger.stderr(
          'when no_sign_msix is true, you must provide the publisher value at "msix_config: publisher" in the pubspec.yaml file');
      exit(-1);
    }
    if (store && publisher.isNullOrEmpty) {
      _logger.stderr(
          'publisher is empty, check "msix_config: publisher" at pubspec.yaml');
      throw 'you can find your store "publisher" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Properties/Publisher';
    }
    if (msixVersion.isNull) msixVersion = '1.0.0.0';
    if (architecture.isNull) architecture = 'x64';
    if (languages.isEmpty) languages.add('en-us');

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!)) {
      throw 'msix version can be only in this format: "1.0.0.0"';
    }

    if (displayName != null && displayName!.length > 256) {
      throw '"display name" is too long, it should be less than 256 characters';
    }

    if (publisherName != null && publisherName!.length > 256) {
      throw '"publisher display name" is too long, it should be less than 256 characters';
    }

    if (!certificatePath.isNull || signToolOptions.isNotEmpty || store) {
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
      certificatePath = '$msixAssetsPath/test_certificate.pfx';
      certificatePassword = '1234';
    }

    if (!['x86', 'x64'].contains(architecture)) {
      throw 'Architecture can be "x86" or "x64", check "msix_config: architecture" at pubspec.yaml';
    }
  }

  /// Validate "flutter build windows" output files
  Future<void> validateWindowsBuildFiles() async {
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

  Future<void> validateAppInstallerConfigValues() async {
    _logger.trace('validating app installer config values');

    if (publishFolderPath.isNullOrEmpty ||
        !await Directory(publishFolderPath!).exists()) {
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

    Package msixPackage =
        packagesConfig.packages.firstWhere((package) => package.name == "msix");
    String path =
        msixPackage.packageUriRoot.toString().replaceAll('file:///', '') +
            'assets';

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

  /// Get multiple configuration values
  List<String> _getMultiConfigValues(dynamic config, String configName) =>
      (config[configName] as String?)
          ?.split(',')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toSet()
          .toList() ??
      [];

  /// Get the protocol activation list
  List<String> _getProtocolsActivation(dynamic config) =>
      _args['protocol-activation'] ??
      (config['protocol_activation'] as String?)
          ?.split(',')
          .map((protocol) => protocol
              .trim()
              .toLowerCase()
              .replaceAll('://', '')
              .replaceAll(':/', '')
              .replaceAll(':', ''))
          .where((protocol) => protocol.isNotEmpty)
          .toSet()
          .toList() ??
      [];
}
