import 'dart:io';
import 'package:args/args.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'utils/log.dart';
import 'utils/extensions.dart';

const String defaultPublisher = 'CN=Msix Testing, O=Msix Testing Corporation, C=US';

class Configuration {
  late ArgResults argResults;
  String msixAssetsPath = '';
  String? appName;
  String? publisherName;
  String? identityName;
  String? msixVersion;
  String? appDescription;
  String? publisher;
  String buildFilesFolder = '${Directory.current.path}/build/windows/runner/Release';
  String? certificatePath;
  String? certificatePassword;
  String? displayName;
  String? architecture;
  String? capabilities;
  String? logoPath;
  String? startMenuIconPath;
  String? tileIconPath;
  String? vsGeneratedImagesFolderPath;
  String? executableFileName;
  String? iconsBackgroundColor;
  bool debugSigning = false;
  bool isUsingTestCertificate = false;
  Iterable<String>? languages;
  String defaultsIconsFolderPath() => '$msixAssetsPath/icons';
  String vcLibsFolderPath() => '$msixAssetsPath/VCLibs';
  String msixToolkitPath() => '$msixAssetsPath/MSIX-Toolkit';

  Future<void> getConfigValues(List<String> arguments) async {
    Log.startTask('getting config values');

    _parseCliArguments(arguments);
    await _getAssetsFolderPath();
    var pubspec = _getPubspec();
    appName = pubspec['name']?.toString();
    appDescription = pubspec['description']?.toString();
    var config = pubspec['msix_config'];

    msixVersion = argResults.read('version', fallback: config?['msix_version']?.toString());
    certificatePath =
        argResults.read('certificate', fallback: config?['certificate_path']?.toString());
    certificatePassword =
        argResults.read('password', fallback: config?['certificate_password']?.toString());
    debugSigning = argResults.wasParsed('debug');

    displayName = config?['display_name']?.toString();
    publisherName = config?['publisher_display_name']?.toString();
    identityName = config?['identity_name']?.toString();
    publisher = config?['publisher']?.toString();
    logoPath = config?['logo_path']?.toString();
    startMenuIconPath = config?['start_menu_icon_path']?.toString();
    tileIconPath = config?['tile_icon_path']?.toString();
    vsGeneratedImagesFolderPath = config?['vs_generated_images_folder_path']?.toString();
    iconsBackgroundColor = config?['icons_background_color']?.toString();
    architecture = config?['architecture']?.toString();
    capabilities = config?['capabilities']?.toString();
    languages = _getLanguages(config);

    Log.completeTask();
  }

  /// Validate the configuration values and set default values
  void validateConfigValues() {
    Log.startTask('validating config values');

    if (appName.isNull) {
      Log.error('App name is empty, check \'appName\' at pubspec.yaml');
      exit(0);
    }
    if (appDescription.isNull) appDescription = appName;
    if (displayName.isNull) displayName = appName!.replaceAll('_', '');
    if (identityName.isNull) identityName = 'com.flutter.${appName!.replaceAll('_', '')}';
    if (publisherName.isNull) publisherName = identityName;
    if (msixVersion.isNull) msixVersion = '1.0.0.0';
    if (architecture.isNull) architecture = 'x64';
    if (capabilities.isNull) capabilities = 'internetClient,location,microphone,webcam';
    if (iconsBackgroundColor.isNull) iconsBackgroundColor = 'transparent';
    if (languages == null) languages = ['en-us'];

    if (!Directory(buildFilesFolder).existsSync()) {
      Log.error(
          'Build files not found as $buildFilesFolder, first run "flutter build windows" then try again');
      exit(0);
    }

    final executables = Directory(buildFilesFolder)
        .listSync()
        .where((file) => file.path.endsWith('.exe'))
        .map((file) => basename(file.path));

    executableFileName = executables.firstWhere((exeName) => exeName == '$appName.exe',
        orElse: () => executables.first);

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!)) {
      Log.error('Msix version can be only in this format: "1.0.0.0"');
      exit(0);
    }

    /// If no certificate was chosen then use test certificate
    if (certificatePath.isNull) {
      if (publisher.isNull) {
        certificatePath = '$msixAssetsPath/test_certificate.pfx';
        certificatePassword = '1234';
        publisher = defaultPublisher;
        isUsingTestCertificate = true;
      }
    } else if (!File(certificatePath!).existsSync()) {
      Log.error(
          'The file certificate not found in: $certificatePath, check "msix_config: certificate_path" at pubspec.yaml');
      exit(0);
    } else if (publisher.isNull) {
      Log.error('Certificate subject is empty, check "msix_config: publisher" at pubspec.yaml');
      Log.warn('see what certificate-subject value is:');
      Log.link(
          'https://drive.google.com/file/d/1oAsnrp2Kf-jZ_kaRjyF5llQ0YZy1IwNe/view?usp=sharing');
      exit(0);
    } else if (extension(certificatePath!) == '.pfx' && certificatePassword.isNull) {
      Log.error(
          'Certificate password is empty, check "msix_config: certificate_password" at pubspec.yaml');
      exit(0);
    }

    if (!['x86', 'x64'].contains(architecture)) {
      Log.error(
          'Architecture can be "x86" or "x64", check "msix_config: architecture" at pubspec.yaml');
      exit(0);
    }

    if (iconsBackgroundColor != 'transparent' && !iconsBackgroundColor!.contains('#'))
      iconsBackgroundColor = '#$iconsBackgroundColor';
    if (iconsBackgroundColor != 'transparent' &&
        !RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$').hasMatch(iconsBackgroundColor!)) {
      Log.error('Icons background color can be only in this format: "#ffffff"');
      exit(0);
    }

    Log.completeTask();
  }

  /// parse the cli arguments
  void _parseCliArguments(List<String> args) {
    Log.startTask('parsing cli arguments');

    var parser = ArgParser()
      ..addOption('password', abbr: 'p')
      ..addOption('certificate', abbr: 'c')
      ..addOption('version', abbr: 'v')
      ..addFlag('debug', abbr: 'd');

    try {
      argResults = parser.parse(args);
    } catch (e) {
      Log.warn('invalid cli arguments: $e');
    }

    Log.completeTask();
  }

  /// Get the assets folder path from the .packages file
  Future<void> _getAssetsFolderPath() async {
    var packagesConfig =
        await loadPackageConfig(File('${Directory.current.path}\\.dart_tool\\package_config.json'));

    var msixPackage = packagesConfig.packages.firstWhere((package) => package.name == "msix");
    var path = msixPackage.packageUriRoot.toString().replaceAll('file:///', '') + 'assets';

    msixAssetsPath = Uri.decodeFull(path);
  }

  /// Get pubspec.yaml content
  dynamic _getPubspec() {
    var pubspecString = File("pubspec.yaml").readAsStringSync();
    var pubspec = loadYaml(pubspecString);
    return pubspec;
  }

  Iterable<String>? _getLanguages(dynamic config) {
    var languagesConfig = config?['languages']?.toString();
    if (languagesConfig != null) {
      var languages =
          languagesConfig.split(',').map((e) => e.trim()).where((element) => element.length > 0);

      if (languages.length > 0) return languages;
    }

    return null;
  }
}
