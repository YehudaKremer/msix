import 'dart:io';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';
import 'package:package_config/package_config.dart';
import 'utils.dart';
import 'constants.dart';

class Configuration {
  late ArgResults argResults;
  String msixAssetsPath = '';
  String? appName;
  String? publisherName;
  String? identityName;
  String? msixVersion;
  String? appDescription;
  String? publisher;
  String buildFilesFolder =
      '${Directory.current.path}/build/windows/runner/Release';
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
  bool isUsingTestCertificate = false;
  String defaultsIconsFolderPath() => '$msixAssetsPath/icons';
  String vcLibsFolderPath() => '$msixAssetsPath/VCLibs';
  String msixToolkitPath() => '$msixAssetsPath/MSIX-Toolkit';

  Future<void> getConfigValues(List<String> args) async {
    stdout.write(white('getting config values..  '));
    _parseCliArguments(args);
    await _getAssetsFolderPath();
    var pubspec = _getPubspec();
    appName = pubspec['name']?.toString();
    appDescription = pubspec['description']?.toString();
    var config = pubspec['msix_config'];

    msixVersion = argResults.read('version',
        fallback: config?['msix_version']?.toString());
    certificatePath = argResults.read('certificate',
        fallback: config?['certificate_path']?.toString());
    certificatePassword = argResults.read('password',
        fallback: config?['certificate_password']?.toString());

    displayName = config?['display_name']?.toString();
    publisherName = config?['publisher_display_name']?.toString();
    identityName = config?['identity_name']?.toString();
    publisher = config?['publisher']?.toString();
    logoPath = config?['logo_path']?.toString();
    startMenuIconPath = config?['start_menu_icon_path']?.toString();
    tileIconPath = config?['tile_icon_path']?.toString();
    vsGeneratedImagesFolderPath =
        config?['vs_generated_images_folder_path']?.toString();
    iconsBackgroundColor = config?['icons_background_color']?.toString();
    architecture = config?['architecture']?.toString();
    capabilities = config?['capabilities']?.toString();

    print(green('[√]'));
  }

  /// parse the cli options
  void _parseCliArguments(List<String> args) {
    var parser = ArgParser()
      ..addOption('password', abbr: 'p')
      ..addOption('certificate', abbr: 'c')
      ..addOption('version', abbr: 'v');

    try {
      argResults = parser.parse(args);
    } catch (e) {
      stdout.write(yellow('invalid cli arguments: $e'));
    }
  }

  /// Get the assets folder path from the .packages file
  Future<void> _getAssetsFolderPath() async {
    var packagesConfig = await loadPackageConfig(
        File('${Directory.current.path}\\.dart_tool\\package_config.json'));

    var msixPackage =
        packagesConfig.packages.firstWhere((package) => package.name == "msix");
    var path =
        msixPackage.packageUriRoot.toString().replaceAll('file:///', '') +
            'assets';

    msixAssetsPath = Uri.decodeFull(path);
  }

  /// Get pubspec.yaml content
  dynamic _getPubspec() {
    var pubspecString = File("pubspec.yaml").readAsStringSync();
    var pubspec = loadYaml(pubspecString);
    return pubspec;
  }

  /// Validate the configuration values and set default values
  void validateConfigValues() {
    stdout.write(white('validate config values..  '));

    if (appName.isNull)
      throw (red('App name is empty, check \'appName\' at pubspec.yaml'));
    if (appDescription.isNull) appDescription = appName;
    if (displayName.isNull) displayName = appName!.replaceAll('_', '');
    if (identityName.isNull)
      identityName = 'com.flutter.${appName!.replaceAll('_', '')}';
    if (publisherName.isNull) publisherName = identityName;
    if (msixVersion.isNull) msixVersion = '1.0.0.0';
    if (architecture.isNull) architecture = 'x64';
    if (capabilities.isNull)
      capabilities = 'internetClient,location,microphone,webcam';
    if (iconsBackgroundColor.isNull) iconsBackgroundColor = 'transparent';

    if (!Directory(buildFilesFolder).existsSync())
      throw (red(
          'Build files not found as $buildFilesFolder, first run "flutter build windows" then try again'));

    final executables = Directory(buildFilesFolder)
        .listSync()
        .where((file) => file.path.endsWith('.exe'))
        .map((file) => basename(file.path));

    executableFileName = executables.firstWhere(
        (exeName) => exeName == '$appName.exe',
        orElse: () => executables.first);

    if (!RegExp(r'^(\*|\d+(\.\d+){3,3}(\.\*)?)$').hasMatch(msixVersion!))
      throw (red('Msix version can be only in this format: "1.0.0.0"'));

    /// If no certificate was chosen then use test certificate
    if (certificatePath.isNull) {
      if (publisher.isNull) {
        certificatePath = '$msixAssetsPath/test_certificate.pfx';
        certificatePassword = '1234';
        publisher = defaultPublisher;
        isUsingTestCertificate = true;
      }
    } else if (!File(certificatePath!).existsSync())
      throw (red(
          'The file certificate not found in: $certificatePath, check "msix_config: certificate_path" at pubspec.yaml'));
    else if (publisher.isNull) {
      print(red(
          'Certificate subject is empty, check "msix_config: publisher" at pubspec.yaml'));
      print(yellow('see what certificate-subject value is:'));
      print(blue(
          'https://drive.google.com/file/d/1oAsnrp2Kf-jZ_kaRjyF5llQ0YZy1IwNe/view?usp=sharing'));
      exit(0);
    } else if (extension(certificatePath!) == '.pfx' &&
        certificatePassword.isNull)
      throw (red(
          'Certificate password is empty, check "msix_config: certificate_password" at pubspec.yaml'));

    if (!['x86', 'x64'].contains(architecture))
      throw (red(
          'Architecture can be "x86" or "x64", check "msix_config: architecture" at pubspec.yaml'));

    if (iconsBackgroundColor != 'transparent' &&
        !iconsBackgroundColor!.contains('#'))
      iconsBackgroundColor = '#$iconsBackgroundColor';
    if (iconsBackgroundColor != 'transparent' &&
        !RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$').hasMatch(iconsBackgroundColor!))
      throw (red(
          'Icons background color can be only in this format: "#ffffff"'));

    print(green('[√]'));
  }
}
