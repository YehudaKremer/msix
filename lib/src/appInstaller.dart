import 'dart:io';
import 'dart:convert' show HtmlEscape, base64Encode;
import 'package:cli_dialog/cli_dialog.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:cli_util/cli_logging.dart';
import 'configuration.dart';

/// Handles the creation of the manifest file
class AppInstaller {
  Configuration _config;
  Logger _logger;

  String get versionsFolderPath => '${_config.publishFolderPath}/versions';
  String get msixVersionPath =>
      '$versionsFolderPath/${_config.appName}_${_config.msixVersion}.msix';

  AppInstaller(this._config, this._logger);

  Future<void> validatePublishVersion() async {
    _logger.trace('validate publish version');

    if (!await File(_config.appInstallerPath).exists()) return;

    var appInstallerContent =
        await File(_config.appInstallerPath).readAsString();
    var appInstallerVersion = appInstallerContent.substring(
        appInstallerContent.indexOf('Version="') + 9,
        appInstallerContent.indexOf(
            '"', appInstallerContent.indexOf('Version="') + 9));
    appInstallerVersion =
        appInstallerVersion.substring(0, appInstallerVersion.lastIndexOf('.'));
    var lastPublishVersion = Version.parse(appInstallerVersion);
    var msixVersion = Version.parse(_config.msixVersion!
        .substring(0, _config.msixVersion!.lastIndexOf('.')));
    var msixVersionRevision =
        _config.msixVersion!.substring(_config.msixVersion!.lastIndexOf('.'));

    if (lastPublishVersion == msixVersion || lastPublishVersion > msixVersion) {
      if (lastPublishVersion == msixVersion) {
        _logger.stdout(
            'You publishing the same version ($lastPublishVersion) as last publish');
      } else {
        _logger.stdout(
            'You publishing older version ($msixVersion) then last publish version ($lastPublishVersion)');
      }

      final dialog = CLI_Dialog(booleanQuestions: [
        [
          'Do you want to increment it to version ${lastPublishVersion.nextPatch} ?',
          'increment'
        ]
      ]);
      final wantToIncrement = dialog.ask()['increment'];
      if (wantToIncrement) {
        _config.msixVersion =
            '${lastPublishVersion.nextPatch}$msixVersionRevision';
      }
    }
  }

  Future<void> _createVersionFolder() async =>
      await Directory(versionsFolderPath).create(recursive: true);

  Future<void> copyMsixToVersionsFolder() async {
    _logger.trace('copy msix to versions folder');

    await _createVersionFolder();
    await File(_config.msixPath).copy(msixVersionPath);
  }

  Future<void> generateAppInstaller() async {
    _logger.trace('generate app installer');

    var appInstallerContent = '''<?xml version="1.0" encoding="utf-8"?>
  <AppInstaller xmlns="http://schemas.microsoft.com/appx/appinstaller/2021"
    Uri="${_config.appInstallerPath}" Version="${_config.msixVersion}">
    <MainPackage Name="${_config.identityName}" Version="${_config.msixVersion}"
      Publisher="${HtmlEscape().convert(_config.publisher!.replaceAll(' = ', '='))}"
      Uri="$msixVersionPath"
      ProcessorArchitecture="${_config.architecture}" />
    <UpdateSettings>
      <OnLaunch HoursBetweenUpdateChecks="${_config.hoursBetweenUpdateChecks}" 
        UpdateBlocksActivation="${_config.updateBlocksActivation}" ShowPrompt="${_config.showPrompt}" />
        ${_config.automaticBackgroundTask ? '<AutomaticBackgroundTask />' : ''}
        ${_config.forceUpdateFromAnyVersion ? '<ForceUpdateFromAnyVersion>true</ForceUpdateFromAnyVersion>' : ''}
    </UpdateSettings>
  </AppInstaller>''';

    await File(_config.appInstallerPath).writeAsString(appInstallerContent);
  }

  Future<void> generateAppInstallerWebSite() async {
    _logger.trace('generate app installer web site');

    var htmlFileContent =
        await File('${_config.msixAssetsPath}/appInstallerSite.html')
            .readAsString();

    htmlFileContent = htmlFileContent.replaceAll(
        'PAGE_TITLE', _config.displayName ?? _config.appName!);
    htmlFileContent = htmlFileContent.replaceAll(
        'PAGE_DESCRIPTION',
        _config.appDescription ??
            '${_config.displayName ?? _config.appName!} installer');
    htmlFileContent = htmlFileContent.replaceAll(
        'PAGE_TITLE', _config.displayName ?? _config.appName!);
    htmlFileContent = htmlFileContent.replaceAll(
        'APP_NAME', _config.displayName ?? _config.appName!);
    htmlFileContent =
        htmlFileContent.replaceAll('APP_VERSION', _config.msixVersion!);
    htmlFileContent = htmlFileContent.replaceAll(
        'APP_INSTALLER_LINK', '${basename(_config.appInstallerPath)}');
    htmlFileContent =
        htmlFileContent.replaceAll('REQUIRED_OS_VERSION', _config.osMinVersion);
    htmlFileContent =
        htmlFileContent.replaceAll('ARCHITECTURE', _config.architecture!);
    htmlFileContent =
        htmlFileContent.replaceAll('PUBLISHER_NAME', _config.publisherName!);

    var logoImage = decodeImage(await File(_config.logoPath ??
            '${_config.defaultsIconsFolderPath}/Square44x44Logo.altform-lightunplated_targetsize-256.png')
        .readAsBytes())!;

    try {
      logoImage = trim(logoImage);
    } catch (e) {}

    Image siteLogo = copyResize(logoImage, width: 192);
    Image favicon = copyResize(logoImage, width: 16, height: 16);

    String base64Logo = base64Encode(encodePng(siteLogo));
    String base64favicon = base64Encode(encodePng(favicon));

    htmlFileContent = htmlFileContent.replaceAll('IMAGE_BASE64', base64Logo);
    htmlFileContent =
        htmlFileContent.replaceAll('FAVICON_BASE64', base64favicon);

    await File('${_config.publishFolderPath}/index.html')
        .writeAsString(htmlFileContent);
  }
}
