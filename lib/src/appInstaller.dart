import 'dart:io';
import 'dart:convert' show HtmlEscape;
import 'configuration.dart';
import 'extensions.dart';
import 'package:cli_util/cli_logging.dart';

/// Handles the creation of the manifest file
class AppInstaller {
  Configuration _config;
  Logger _logger;
  late String publishMsixPath;

  AppInstaller(this._config, this._logger) {
    publishMsixPath =
        '${_config.publishFolderPath}/versions/${_config.appName}_${_config.msixVersion}.msix';
  }

  Future<void> copyMsixToVersionsFolder() async => await File(
          '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix')
      .copy(publishMsixPath);

  Future<void> generateAppInstaller() async {
    _logger.trace('generate app installer');

    var appInstallerContent = '''<?xml version="1.0" encoding="utf-8"?>
  <AppInstaller xmlns="http://schemas.microsoft.com/appx/appinstaller/2021"
    Uri="${_config.installerPath}" Version="${_config.msixVersion}">
    <MainPackage Name="${_config.identityName}" Version="${_config.msixVersion}"
      Publisher="${HtmlEscape().convert(_config.publisher!.replaceAll(' = ', '='))}"
      Uri="$publishMsixPath"
      ProcessorArchitecture="${_config.architecture}" />
    <UpdateSettings>
      <OnLaunch HoursBetweenUpdateChecks="${_config.hoursBetweenUpdateChecks}" 
        UpdateBlocksActivation="${_config.updateBlocksActivation}" ShowPrompt="${_config.showPrompt}" />
    </UpdateSettings>
    ${_config.automaticBackgroundTask ? '<AutomaticBackgroundTask />' : ''}
    ${_config.forceUpdateFromAnyVersion ? '<ForceUpdateFromAnyVersion>true</ForceUpdateFromAnyVersion>' : ''}
  </AppInstaller>''';

    await File(
            '${_config.publishFolderPath}/${_config.outputName ?? _config.appName}.appinstaller')
        .writeAsString(appInstallerContent);
  }
}
