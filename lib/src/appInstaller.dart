import 'dart:io';
import 'package:path/path.dart' as path;
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

  String get publishVersionsFolderPath =>
      '${_config.publishFolderPath}/versions';
  String get publishMsixPath =>
      '$publishVersionsFolderPath/${_config.appName}_${_config.msixVersion}.msix';
  String get appInstallerPath =>
      '${_config.publishFolderPath}/${path.basename(_config.appInstallerUri!)}';
  File get htmlFile =>
      File('${_config.appInstallerWebSitePath}/web/index.html');
  File get mainFile => File('${_config.appInstallerWebSitePath}/lib/main.dart');

  AppInstaller(this._config, this._logger);

  Future<void> validatePublishVersion() async {
    _logger.trace('validate publish version');

    if (!await File(appInstallerPath).exists()) return;

    var appInstallerContent = await File(appInstallerPath).readAsString();
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

  Future<void> copyMsixToVersionsFolder() async {
    _logger.trace('copy msix to versions folder');

    await Directory(publishVersionsFolderPath).create(recursive: true);
    await File(
            '${_config.outputPath ?? _config.buildFilesFolder}/${_config.outputName ?? _config.appName}.msix')
        .copy(publishMsixPath);
  }

  Future<void> copyCertificateToVersionsFolder() async {
    _logger.trace('copy certificate to versions folder');

    await Directory(publishVersionsFolderPath).create(recursive: true);
    await File(_config.certificatePath!).copy(
        '$publishVersionsFolderPath/${basename(_config.certificatePath!)}');
  }

  Future<void> generateAppInstaller() async {
    _logger.trace('generate app installer');

    var appInstallerContent = '''<?xml version="1.0" encoding="utf-8"?>
  <AppInstaller xmlns="http://schemas.microsoft.com/appx/appinstaller/2021"
    Uri="${_config.appInstallerUri}" Version="${_config.msixVersion}">
    <MainPackage Name="${_config.identityName}" Version="${_config.msixVersion}"
      Publisher="${HtmlEscape().convert(_config.publisher!.replaceAll(' = ', '='))}"
      Uri="$publishMsixPath"
      ProcessorArchitecture="${_config.architecture}" />
    <UpdateSettings>
      <OnLaunch HoursBetweenUpdateChecks="${_config.hoursBetweenUpdateChecks}" 
        UpdateBlocksActivation="${_config.updateBlocksActivation}" ShowPrompt="${_config.showPrompt}" />
        ${_config.automaticBackgroundTask ? '<AutomaticBackgroundTask />' : ''}
        ${_config.forceUpdateFromAnyVersion ? '<ForceUpdateFromAnyVersion>true</ForceUpdateFromAnyVersion>' : ''}
    </UpdateSettings>
  </AppInstaller>''';

    await File(appInstallerPath).writeAsString(appInstallerContent);
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
    mainFileContent = mainFileContent.replaceAll('CERTIFICATE_LINK',
        '$publishVersionsFolderPath/${basename(_config.certificatePath!)}');
    mainFileContent = mainFileContent.replaceAll(
        'MSIX_LINK', publishMsixPath.replaceAll('\\', '/'));
    mainFileContent = mainFileContent.replaceAll(
        'APP_NAME', _config.displayName ?? _config.appName!);
    mainFileContent =
        mainFileContent.replaceAll('APP_VERSION', _config.msixVersion!);
    mainFileContent = mainFileContent.replaceAll(
        'APP_INSTALLER_LINK', _config.appInstallerUri!);
    mainFileContent =
        mainFileContent.replaceAll('REQUIRED_OS_VERSION', _config.osMinVersion);
    mainFileContent =
        mainFileContent.replaceAll('ARCHITECTURE', _config.architecture!);
    mainFileContent =
        mainFileContent.replaceAll('PUBLISHER_NAME', _config.publisherName!);

    var webSiteLogoPath = '${_config.appInstallerWebSitePath}/logo.png';
    var webSiteFaviconPath =
        '${_config.appInstallerWebSitePath}/web/favicon.png';

    try {
      await mainFile.writeAsString(mainFileContent);

      var logoFile = File(_config.logoPath ??
          '${_config.defaultsIconsFolderPath}/Square44x44Logo.altform-lightunplated_targetsize-256.png');

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
      await _copyDirectory(
          Directory('${_config.appInstallerWebSitePath}/build/web'),
          Directory('${_config.publishFolderPath}/website'));
    } catch (e) {
      throw e;
    } finally {
      await _restoreAppInstallerWebSiteContent(
          htmlFileOriginalContent, mainFileOriginalContent);
      await File(webSiteLogoPath).deleteIfExists();
      await File(webSiteFaviconPath).deleteIfExists();
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(
            path.join(destination.absolute.path, path.basename(entity.path)));
        await newDirectory.create();
        await _copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        await entity
            .copy(path.join(destination.path, path.basename(entity.path)));
      }
    }
  }

  Future<void> _restoreAppInstallerWebSiteContent(
      String htmlFileContent, String mainFileContent) async {
    await htmlFile.writeAsString(htmlFileContent);
    await mainFile.writeAsString(mainFileContent);
    await File('${_config.appInstallerWebSitePath}/logo.png').deleteIfExists();
  }
}
