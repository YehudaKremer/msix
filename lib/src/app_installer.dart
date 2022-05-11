import 'dart:io';
import 'dart:convert' show HtmlEscape, base64Encode;
import 'package:cli_dialog/cli_dialog.dart' show CLI_Dialog;
import 'package:get_it/get_it.dart';
import 'package:image/image.dart'
    show Image, copyResize, decodeImage, encodePng, trim;
import 'package:path/path.dart' show basename;
import 'package:pub_semver/pub_semver.dart' show Version;
import 'package:cli_util/cli_logging.dart' show Logger;
import 'configuration.dart';

/// Handles the creation of .appinstaller file and msix versions
class AppInstaller {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  String get _versionsFolderPath => '${_config.publishFolderPath}/versions';
  String get _msixVersionPath =>
      '$_versionsFolderPath/${_config.appName}_${_config.msixVersion}.msix';

  /// Ask the user if he want to increment the version
  /// if the current publish version is the same or lower than the last published version.
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

  /// Copy the .appinstaller file to the publish folder ("publish_folder_path")
  Future<void> copyMsixToVersionsFolder() async {
    _logger.trace('copy msix to versions folder');

    await Directory(_versionsFolderPath).create(recursive: true);
    await File(_config.msixPath).copy(_msixVersionPath);
  }

  /// Generate the .appinstaller file into the publish folder ("publish_folder_path")
  Future<void> generateAppInstaller() async {
    _logger.trace('generate app installer');

    var appInstallerContent = '''<?xml version="1.0" encoding="utf-8"?>
  <AppInstaller xmlns="http://schemas.microsoft.com/appx/appinstaller/${_config.appInstallerSchemeVersion}"
    Uri="${_config.appInstallerPath}" Version="${_config.msixVersion}">
    <MainPackage Name="${_config.identityName}" Version="${_config.msixVersion}"
      Publisher="${const HtmlEscape().convert(_config.publisher!.replaceAll(' = ', '='))}"
      Uri="$_msixVersionPath"
      ProcessorArchitecture="${_config.architecture}" />
    <UpdateSettings>
      <OnLaunch HoursBetweenUpdateChecks="${_config.hoursBetweenUpdateChecks}" 
        UpdateBlocksActivation="${_config.updateBlocksActivation}" ShowPrompt="${_config.showPrompt}" />
        ${_config.automaticBackgroundTask ? '<AutomaticBackgroundTask />' : ''}
        ${_config.forceUpdateFromAnyVersion ? '<ForceUpdateFromAnyVersion>true</ForceUpdateFromAnyVersion>' : ''}
    </UpdateSettings>
  </AppInstaller>''';

    //clear empty rows
    appInstallerContent = appInstallerContent.replaceAll('    \n', '');

    await File(_config.appInstallerPath).writeAsString(appInstallerContent);
  }

  /// Create index.html file that enable the users to download the .appinstaller file,
  /// and save it into the publish folder ("publish_folder_path").
  Future<void> generateAppInstallerWebSite() async {
    _logger.trace('generate app installer web site');

    webInstallerSite = webInstallerSite.replaceAll(
        'PAGE_TITLE', _config.displayName ?? _config.appName!);
    webInstallerSite = webInstallerSite.replaceAll(
        'PAGE_DESCRIPTION',
        _config.appDescription ??
            '${_config.displayName ?? _config.appName!} installer');
    webInstallerSite = webInstallerSite.replaceAll(
        'PAGE_TITLE', _config.displayName ?? _config.appName!);
    webInstallerSite = webInstallerSite.replaceAll(
        'APP_NAME', _config.displayName ?? _config.appName!);
    webInstallerSite =
        webInstallerSite.replaceAll('APP_VERSION', _config.msixVersion!);
    webInstallerSite = webInstallerSite.replaceAll(
        'APP_INSTALLER_LINK', basename(_config.appInstallerPath));
    webInstallerSite = webInstallerSite.replaceAll(
        'REQUIRED_OS_VERSION', _config.osMinVersion);
    webInstallerSite =
        webInstallerSite.replaceAll('ARCHITECTURE', _config.architecture!);
    webInstallerSite =
        webInstallerSite.replaceAll('PUBLISHER_NAME', _config.publisherName!);

    var logoImage = decodeImage(await File(_config.logoPath ??
            '${_config.defaultsIconsFolderPath}/Square44x44Logo.altform-lightunplated_targetsize-256.png')
        .readAsBytes())!;

    try {
      logoImage = trim(logoImage);
    } catch (_) {}

    Image siteLogo = copyResize(logoImage, width: 192);
    Image favicon = copyResize(logoImage, width: 16, height: 16);

    String base64Logo = base64Encode(encodePng(siteLogo));
    String base64favicon = base64Encode(encodePng(favicon));

    webInstallerSite = webInstallerSite.replaceAll('IMAGE_BASE64', base64Logo);
    webInstallerSite =
        webInstallerSite.replaceAll('FAVICON_BASE64', base64favicon);

    await File('${_config.publishFolderPath}/index.html')
        .writeAsString(webInstallerSite);
  }
}

var webInstallerSite = '''
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="icon" type="image/png" href="data:image/png;base64, FAVICON_BASE64" />
    <meta name="description" content="PAGE_DESCRIPTION">
    <title>PAGE_TITLE</title>
</head>

<body>

    <div class="flex m-14">
        <div class="mr-5">
            <img class="w-48" src="data:image/png;base64, IMAGE_BASE64" alt="logo">
        </div>
        <div>
            <h1 class="text-3xl text-sky-500 mb-5">APP_NAME</h1>
            <h3 class="text-xl text-gray-600  mb-8">Version APP_VERSION</h3>
            <button class="bg-sky-500 hover:bg-sky-400 transition-colors rounded-md text-white px-8 py-1  mb-3"
                onclick="download()">Install</button>
            <a href="https://go.microsoft.com/fwlink/?linkid=870616" target="_blank">
                <p class="text-sky-500  mb-5">Troubleshoot installation</p>
            </a>
            <h3 class="text-xl text-gray-600 mb-4">Application Information</h3>

            <div class="flex text-gray-500">
                <div class="font-bold mr-14">
                    <div class="mb-4">Version</div>
                    <div class="mb-4">Required Operating System</div>
                    <div class="mb-4">Architectures</div>
                    <div class="mb-4">Publisher</div>
                </div>
                <div>
                    <div class="mb-4">APP_VERSION</div>
                    <div class="mb-4">REQUIRED_OS_VERSION</div>
                    <div class="mb-4">ARCHITECTURE</div>
                    <div class="mb-4">PUBLISHER_NAME</div>
                </div>
            </div>

        </div>
    </div>

    <script>
        function download() {
            var a = document.createElement("a");
            a.href = '/APP_INSTALLER_LINK';
            a.setAttribute("download", 'APP_INSTALLER_LINK');
            a.click();
        }
    </script>
</body>

</html>
''';
