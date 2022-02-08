import 'dart:io';
import 'dart:convert' show HtmlEscape;
import 'package:cli_dialog/cli_dialog.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:cli_util/cli_logging.dart';
import 'configuration.dart';

/// Handles the creation of the manifest file
class AppInstaller {
  Configuration _config;
  Logger _logger;

  String get publishFolderPath => '${_config.publishFolderPath}/versions';
  String get publishMsixPath =>
      '$publishFolderPath/${_config.appName}_${_config.msixVersion}.msix';
  String get appInstallerPath =>
      '${_config.publishFolderPath}/${_config.outputName ?? _config.appName}.appinstaller';

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

    await Directory(publishFolderPath).create(recursive: true);
    await File(
            '${_config.outputPath ?? _config.buildFilesFolder}/${_config.outputName ?? _config.appName}.msix')
        .copy(publishMsixPath);
  }

  Future<void> generateAppInstaller() async {
    _logger.trace('generate app installer');

    var appInstallerContent = '''<?xml version="1.0" encoding="utf-8"?>
  <AppInstaller xmlns="http://schemas.microsoft.com/appx/appinstaller/2021"
    Uri="$appInstallerPath" Version="${_config.msixVersion}">
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
}
