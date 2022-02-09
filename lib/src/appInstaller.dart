import 'dart:io';
import 'dart:convert' show HtmlEscape;
import 'package:cli_dialog/cli_dialog.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:cli_util/cli_logging.dart';
import 'configuration.dart';
import 'extensions.dart';

/// Handles the creation of the manifest file
class AppInstaller {
  Configuration _config;
  Logger _logger;

  String get versionsFolderPath => '${_config.publishFolderPath}/versions';
  String get msixVersionPath =>
      '$versionsFolderPath/${_config.appName}_${_config.msixVersion}.msix';

  File get htmlFile =>
      File('${_config.appInstallerWebSitePath}/web/index.html');
  File get mainFile => File('${_config.appInstallerWebSitePath}/lib/main.dart');
  String get webSiteLogoPath => '${_config.appInstallerWebSitePath}/logo.png';
  String get webSiteFaviconPath =>
      '${_config.appInstallerWebSitePath}/web/favicon.png';
  String get defaultLogoPath =>
      '${_config.defaultsIconsFolderPath}/Square44x44Logo.altform-lightunplated_targetsize-256.png';

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

  Future<void> copyCertificateToVersionsFolder() async {
    _logger.trace('copy certificate to versions folder');

    await _createVersionFolder();
    await File(_config.certificatePath!)
        .copy('$versionsFolderPath/${basename(_config.certificatePath!)}');
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

    var htmlFileContent = await htmlFile.readAsString();
    var htmlFileOriginalContent = htmlFileContent;

    htmlFileContent = htmlFileContent.replaceAll(
        'PAGE_TITLE', _config.displayName ?? _config.appName!);
    htmlFileContent = htmlFileContent.replaceAll(
        'PAGE_DESCRIPTION',
        _config.appDescription ??
            '${_config.displayName ?? _config.appName!} installer');

    await htmlFile.writeAsString(htmlFileContent);

    var mainFileContent = await mainFile.readAsString();
    var mainFileOriginalContent = mainFileContent;

    mainFileContent = mainFileContent.replaceAll(
        'PAGE_TITLE', _config.displayName ?? _config.appName!);
    mainFileContent = mainFileContent.replaceAll(
        'APP_NAME', _config.displayName ?? _config.appName!);
    mainFileContent =
        mainFileContent.replaceAll('APP_VERSION', _config.msixVersion!);
    mainFileContent = mainFileContent.replaceAll(
        'APP_INSTALLER_LINK', '/${basename(_config.appInstallerPath)}');
    mainFileContent =
        mainFileContent.replaceAll('REQUIRED_OS_VERSION', _config.osMinVersion);
    mainFileContent =
        mainFileContent.replaceAll('ARCHITECTURE', _config.architecture!);
    mainFileContent =
        mainFileContent.replaceAll('PUBLISHER_NAME', _config.publisherName!);

    try {
      await mainFile.writeAsString(mainFileContent);

      var logoFile = File(_config.logoPath ?? defaultLogoPath);

      await logoFile.copy(webSiteLogoPath);
      await logoFile.copy(webSiteFaviconPath);

      var buildAppInstallerWebSiteProcess = await Process.run(
          'flutter', ['build', 'web'],
          runInShell: true, workingDirectory: _config.appInstallerWebSitePath);

      if (buildAppInstallerWebSiteProcess.exitCode != 0) {
        _logger.stderr(buildAppInstallerWebSiteProcess.stdout);
        throw buildAppInstallerWebSiteProcess.stderr;
      }

      await Directory('${_config.publishFolderPath}/website')
          .create(recursive: true);
      await Directory('${_config.appInstallerWebSitePath}/build/web')
          .copyDirectory(Directory('${_config.publishFolderPath}'));
    } catch (e) {
      throw e;
    } finally {
      await _restoreAppInstallerWebSiteContent(
          htmlFileOriginalContent, mainFileOriginalContent);
      await File(defaultLogoPath).copy(webSiteLogoPath);
      await File(defaultLogoPath).copy(webSiteFaviconPath);
    }
  }

  Future<void> _restoreAppInstallerWebSiteContent(
      String htmlFileContent, String mainFileContent) async {
    await htmlFile.writeAsString(htmlFileContent);
    await mainFile.writeAsString(mainFileContent);
  }
}
