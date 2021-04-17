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
  String? vsGeneratedIconsFolderPath;
  String? executableFileName;
  String? iconsBackgroundColor;
  List<String>? signtoolOptions;
  String? protocolActivation;
  String? fileExtension;
  bool debugSigning = false;
  bool isUsingTestCertificate = false;
  Iterable<String>? languages;
  String defaultsIconsFolderPath() => '$msixAssetsPath/icons';
  String vcLibsFolderPath() => '$msixAssetsPath/VCLibs';
  String msixToolkitPath() => '$msixAssetsPath/MSIX-Toolkit';

  Future<void> getConfigValues(List<String> arguments) async {
    _parseCliArguments(arguments);
    await _getAssetsFolderPath();
    var pubspec = _getPubspec();
    appName = pubspec['name']?.toString();
    appDescription = pubspec['description']?.toString();
    var config = pubspec['msix_config'];
    msixVersion =
        argResults.read('v') ?? argResults.read('version') ?? config?['msix_version']?.toString();
    certificatePath = argResults.read('c') ??
        argResults.read('certificate') ??
        config?['certificate_path']?.toString();
    certificatePassword = argResults.read('p') ??
        argResults.read('password') ??
        config?['certificate_password']?.toString();
    debugSigning = argResults.wasParsed('debug') || argResults.wasParsed('d');
    displayName = argResults.read('dn') ?? config?['display_name']?.toString();
    publisherName = argResults.read('pdn') ?? config?['publisher_display_name']?.toString();
    identityName = argResults.read('in') ?? config?['identity_name']?.toString();
    publisher = argResults.read('pu') ?? config?['publisher']?.toString();
    logoPath = argResults.read('lp') ?? config?['logo_path']?.toString();
    startMenuIconPath = argResults.read('smip') ?? config?['start_menu_icon_path']?.toString();
    tileIconPath = argResults.read('tip') ?? config?['tile_icon_path']?.toString();
    vsGeneratedIconsFolderPath =
        argResults.read('vsi') ?? config?['vs_generated_images_folder_path']?.toString();
    iconsBackgroundColor = argResults.read('ibc') ?? config?['icons_background_color']?.toString();
    signtoolOptions = (argResults.read('so') ?? config?['signtool_options'])
        ?.toString()
        .split(' ')
        .where((o) => o.trim().length > 0)
        .toList();
    protocolActivation =
        (argResults.read('pa') ?? config?['protocol_activation'])?.toString().replaceAll(':', '');
    fileExtension = argResults.read('fe') ?? config?['file_extension']?.toString();
    if (fileExtension != null && !fileExtension!.startsWith('.')) {
      fileExtension = '.$fileExtension';
    }
    architecture = argResults.read('a') ?? config?['architecture']?.toString();
    capabilities = argResults.read('cap') ?? config?['capabilities']?.toString();
    languages = _getLanguages(config);
  }

  /// Validate the configuration values and set default values
  void validateConfigValues() {
    Log.startingTask('validating config values');

    if (appName.isNull) {
      Log.error('App name is empty, check \'appName\' at pubspec.yaml');
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
    }

    final executables = Directory(buildFilesFolder)
        .listSync()
        .where((file) => file.path.endsWith('.exe'))
        .map((file) => basename(file.path));

    executableFileName = executables.firstWhere((exeName) => exeName == '$appName.exe',
        orElse: () => executables.first);

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!)) {
      Log.error('Msix version can be only in this format: "1.0.0.0"');
    }

    /// If no certificate was chosen then use test certificate
    if (certificatePath.isNull) {
      certificatePath = '$msixAssetsPath/test_certificate.pfx';
      certificatePassword = '1234';
      publisher = defaultPublisher;
      isUsingTestCertificate = true;
    } else if (!File(certificatePath!).existsSync()) {
      Log.error(
          'The file certificate not found in: $certificatePath, check "msix_config: certificate_path" at pubspec.yaml');
    } else if (publisher.isNull) {
      Log.error('Certificate subject is empty, check "msix_config: publisher" at pubspec.yaml',
          andExit: false);
      Log.warn('see what certificate-subject value is:');
      Log.link(
          'https://drive.google.com/file/d/1oAsnrp2Kf-jZ_kaRjyF5llQ0YZy1IwNe/view?usp=sharing');
      exit(0);
    } else if (extension(certificatePath!) == '.pfx' && certificatePassword.isNull) {
      Log.error(
          'Certificate password is empty, check "msix_config: certificate_password" at pubspec.yaml');
    }

    if (!['x86', 'x64'].contains(architecture)) {
      Log.error(
          'Architecture can be "x86" or "x64", check "msix_config: architecture" at pubspec.yaml');
    }

    if (iconsBackgroundColor != 'transparent' && !iconsBackgroundColor!.contains('#'))
      iconsBackgroundColor = '#$iconsBackgroundColor';

    if (iconsBackgroundColor != 'transparent' &&
        !RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$').hasMatch(iconsBackgroundColor!)) {
      Log.error('Icons background color can be only in this format: "#ffffff"');
    }

    Log.taskCompleted();
  }

  bool haveAnyIconFromUser() =>
      !logoPath.isNull || !startMenuIconPath.isNull || !tileIconPath.isNull;

  /// parse the cli arguments
  void _parseCliArguments(List<String> args) {
    Log.startingTask('parsing cli arguments');

    var parser = ArgParser()
      ..addOption('password')
      ..addOption('p') // display_name
      ..addOption('certificate')
      ..addOption('c') // display_name
      ..addOption('version')
      ..addOption('v') // display_name
      ..addOption('dn') // display_name
      ..addOption('pdn') // publisher_display_name
      ..addOption('in') // identity_name
      ..addOption('pu') // publisher
      ..addOption('lp') // logo_path
      ..addOption('smip') // start_menu_icon_path
      ..addOption('tip') // tile_icon_path
      ..addOption('vsi') // vs_generated_images_folder_path
      ..addOption('ibc') // icons_background_color
      ..addOption('so') // signtool_options
      ..addOption('pa') // protocol_activation
      ..addOption('fe') // file_extension
      ..addOption('a') // architecture
      ..addOption('cap') // capabilities
      ..addOption('l') // languages
      ..addFlag('debug') // debug
      ..addOption('d');

    try {
      argResults = parser.parse(args);
    } catch (e) {
      Log.error('invalid cli arguments: $e');
    }

    Log.taskCompleted();
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
    var languagesConfig = argResults.read('l') ?? config?['languages']?.toString();
    if (languagesConfig != null) {
      var languages =
          languagesConfig.split(',').map((e) => e.trim()).where((element) => element.length > 0);

      if (languages.length > 0) return languages;
    }

    return null;
  }
}
