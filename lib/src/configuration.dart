import 'dart:io';
import 'package:args/args.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'extensions.dart';
import 'log.dart';

class Configuration {
  Log _log;
  late ArgResults argResults;
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
  String? outputPath;
  String? outputName;
  bool debugSigning = false;
  bool store = false;
  bool dontInstallCert = false;
  bool addExecutionAlias = false;
  bool createWithDebugBuildFiles = false;
  Iterable<String>? languages;
  String defaultsIconsFolderPath() => '$msixAssetsPath/icons';
  String vcLibsFolderPath() => '$msixAssetsPath/VCLibs';
  String msixToolkitPath() => '$msixAssetsPath/MSIX-Toolkit';
  String iconsGeneratorPath() => '$msixAssetsPath/IconsGenerator';
  String pubspecYamlPath = "pubspec.yaml";

  Configuration(this._log);

  /// Gets the configuration values from pubspec.yaml file and from [arguments]
  Future<void> getConfigValues(List<String> arguments) async {
    _parseCliArguments(arguments);
    await _getMsixAssetsFolderPath();
    var pubspec = await _getPubspec();
    appName = pubspec['name']?.toString();
    appDescription = pubspec['description']?.toString();
    var config = pubspec['msix_config'];
    msixVersion =
        argResults.read('version') ?? config?['msix_version']?.toString();
    certificatePath = argResults.read('certificate-path') ??
        config?['certificate_path']?.toString();
    certificatePassword = argResults.read('certificate-password') ??
        config?['certificate_password']?.toString();
    outputPath =
        argResults.read('output-path') ?? config?['output_path']?.toString();
    outputName =
        argResults.read('output-name') ?? config?['output_name']?.toString();
    debugSigning = argResults.wasParsed('debug-signing');
    addExecutionAlias = argResults.wasParsed('add-execution-alias') ||
        config?['add_execution_alias']?.toString().toLowerCase() == 'true';
    dontInstallCert = argResults.wasParsed('dont-install-certificate') ||
        config?['dont_install_cert']?.toString().toLowerCase() == 'true';
    if (dontInstallCert) numberOfAllTasks--;
    store = argResults.wasParsed('store') ||
        config?['store']?.toString().toLowerCase() == 'true';
    if (store) numberOfAllTasks -= 2;
    createWithDebugBuildFiles = argResults.wasParsed('debug') ||
        config?['debug']?.toString().toLowerCase() == 'true';
    if (createWithDebugBuildFiles)
      buildFilesFolder = buildFilesFolder.replaceFirst('Release', 'Debug');
    displayName =
        argResults.read('display-name') ?? config?['display_name']?.toString();
    publisherName = argResults.read('publisher-display-name') ??
        config?['publisher_display_name']?.toString();
    publisher =
        argResults.read('publisher') ?? config?['publisher']?.toString();
    identityName = argResults.read('identity-name') ??
        config?['identity_name']?.toString();
    logoPath = argResults.read('logo-path') ?? config?['logo_path']?.toString();
    if (logoPath.isNull) numberOfAllTasks--;
    signToolOptions =
        (argResults.read('signtool-options') ?? config?['signtool_options'])
            ?.toString()
            .split(' ')
            .where((o) => o.trim().length > 0)
            .toList();
    protocolActivation = (argResults.read('protocol-activation') ??
            config?['protocol_activation'])
        ?.toString()
        .replaceAll(':', '');
    fileExtension = argResults.read('file-extension') ??
        config?['file_extension']?.toString();
    if (fileExtension != null && !fileExtension!.startsWith('.')) {
      fileExtension = '.$fileExtension';
    }
    architecture =
        argResults.read('architecture') ?? config?['architecture']?.toString();
    capabilities =
        argResults.read('capabilities') ?? config?['capabilities']?.toString();
    languages = _getLanguages(config);

// After got the configuration values, time to validate them
    await validateConfigValues();
  }

  /// Validate the configuration values and set default values
  Future<void> validateConfigValues() async {
    const taskName = 'validating config values';
    _log.startingTask(taskName);

    if (appName.isNull) {
      _log.errorAndExit(AppNameException(
          'App name is empty, check the general \'name:\' property at pubspec.yaml'));
    }
    if (appDescription.isNull) appDescription = appName;
    if (displayName.isNull) displayName = _cleanAppName();
    if (identityName.isNull) {
      if (store) {
        _log.error(
            'identity name is empty, check "msix_config: identity_name" at pubspec.yaml');
        _log.warn(
            'you can find your store "identity_name" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Identity/Name');
        exit(-1);
      } else {
        identityName = 'com.flutter.${_cleanAppName()}';
      }
    } else {
      if (!RegExp(r'^[a-zA-Z0-9.-]{3,50}$').hasMatch(identityName!)) {
        _log.error(
            'invalid identity name ("identity_name"): "$identityName". need to be a string between 3 and 50 characters in length that consists of alpha-numeric, period, and dash characters.');
        exit(-1);
      }
    }
    if (publisherName.isNull) {
      if (store) {
        _log.error(
            'publisher display name is empty, check "msix_config: publisher_display_name" at pubspec.yaml');
        _log.warn(
            'you can find your store "publisher_display_name" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Properties/PublisherDisplayName');
        exit(-1);
      } else {
        publisherName = identityName;
      }
    }
    if (store && publisher.isNullOrEmpty) {
      _log.error(
          'publisher is empty, check "msix_config: publisher" at pubspec.yaml');
      _log.warn(
          'you can find your store "publisher" in https://partner.microsoft.com/en-us/dashboard > Product > Product identity > Package/Properties/Publisher');
      exit(-1);
    }
    if (msixVersion.isNull) msixVersion = '1.0.0.0';
    if (architecture.isNull) architecture = 'x64';
    if (capabilities.isNull)
      capabilities = 'internetClient,location,microphone,webcam';
    if (languages == null) languages = ['en-us'];

    if (!(await Directory(buildFilesFolder).exists())) {
      _log.errorAndExit(BuildFilesException(
          'Build files not found at $buildFilesFolder, first run "flutter build windows" then try again'));
    }

    executableFileName = await Directory(buildFilesFolder)
        .list()
        .firstWhere(
            (file) =>
                file.path.endsWith('.exe') &&
                !file.path.contains('PSFLauncher64.exe'),
            orElse: () => Directory(buildFilesFolder).listSync().first)
        .then((file) => basename(file.path));

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!)) {
      _log.errorAndExit(VersionException(
          'Msix version can be only in this format: "1.0.0.0"'));
    }

    if (!certificatePath.isNull || signToolOptions != null || store) {
      if (!certificatePath.isNull) {
        if (!(await File(certificatePath!).exists())) {
          _log.errorAndExit(CertificateException(
              'The file certificate not found in: $certificatePath, check "msix_config: certificate_path" at pubspec.yaml'));
        }

        if (extension(certificatePath!) == '.pfx' &&
            certificatePassword.isNull) {
          _log.errorAndExit(CertificatePasswordException(
              'Certificate password is empty, check "msix_config: certificate_password" at pubspec.yaml'));
        }
      }
    } else {
      /// If no certificate was chosen then use test certificate
      certificatePath = '$msixAssetsPath/test_certificate.pfx';
      certificatePassword = '1234';
    }

    if (!['x86', 'x64'].contains(architecture)) {
      _log.errorAndExit(ArchitectureException(
          'Architecture can be "x86" or "x64", check "msix_config: architecture" at pubspec.yaml'));
    }

    _log.taskCompleted(taskName);
  }

  bool haveLogoPath() => !logoPath.isNull;

  /// parse the cli arguments
  void _parseCliArguments(List<String> args) {
    const taskName = 'parsing cli arguments';
    _log.startingTask(taskName);

    var parser = ArgParser()
      ..addOption('certificate-password', abbr: 'p')
      ..addOption('certificate-path', abbr: 'c')
      ..addOption('version', abbr: 'v')
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
      ..addFlag('store')
      ..addFlag('debug-signing')
      ..addFlag('add-execution-alias')
      ..addFlag('dont-install-certificate')
      ..addFlag('debug')
      ..addFlag('release');

    try {
      argResults = parser.parse(args);
    } catch (e) {
      _log.errorAndExit(ArgumentsException('invalid cli arguments: $e'));
    }

    _log.taskCompleted(taskName);
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

  Iterable<String>? _getLanguages(dynamic config) {
    var languagesConfig =
        argResults.read('languages') ?? config?['languages']?.toString();
    if (languagesConfig != null) {
      var languages = languagesConfig
          .split(',')
          .map((e) => e.trim())
          .where((element) => element.length > 0);

      if (languages.length > 0) return languages;
    }

    return null;
  }

  String _cleanAppName() => appName!.replaceAll('_', '');
}

class VersionException extends GeneralException {
  VersionException(String message) : super(message);
}

class AppNameException extends GeneralException {
  AppNameException(String message) : super(message);
}

class BuildFilesException extends GeneralException {
  BuildFilesException(String message) : super(message);
}

class AssetsFolderException extends GeneralException {
  AssetsFolderException(String message) : super(message);
}

class CertificateException extends GeneralException {
  CertificateException(String message) : super(message);
}

class CertificatePasswordException extends GeneralException {
  CertificatePasswordException(String message) : super(message);
}

class ArchitectureException extends GeneralException {
  ArchitectureException(String message) : super(message);
}

class ArgumentsException extends GeneralException {
  ArgumentsException(String message) : super(message);
}
