import 'dart:io';
import 'package:path/path.dart';
import 'utils.dart';
import 'configuration.dart';
import 'constants.dart';

class MsixFiles {
  Configuration _configuration;
  List<File> _vCLibsFiles;
  MsixFiles(this._configuration);

  Future<void> createIconsFolder() async {
    stdout.write(white('create icons folder..    '));

    var iconsFolderPath = '${_configuration.buildFilesFolder}\\icons';
    try {
      await Directory(iconsFolderPath).create();
    } catch (e) {
      throw (red('fail to create icons folder in $iconsFolderPath: $e'));
    }

    print(green('done!'));
  }

  Future<void> copyIcons() async {
    stdout.write(white('copy icons..    '));

    /// Use the logo for all icons if they null
    if (!isNullOrStringNull(_configuration.logoPath)) {
      if (isNullOrStringNull(_configuration.startMenuIconPath))
        _configuration.startMenuIconPath = _configuration.logoPath;

      if (isNullOrStringNull(_configuration.tileIconPath))
        _configuration.tileIconPath = _configuration.logoPath;
    }

    _configuration.logoPath = await _copyIcon(
        _configuration.logoPath, File('${_configuration.defaultsIconsFolderPath()}/icon.png').path);

    _configuration.startMenuIconPath = await _copyIcon(_configuration.startMenuIconPath,
        File('${_configuration.defaultsIconsFolderPath()}/44_44.png').path);

    _configuration.tileIconPath = await _copyIcon(_configuration.tileIconPath,
        File('${_configuration.defaultsIconsFolderPath()}/150_150.png').path);

    print(green('done!'));
  }

  Future<void> generateAppxManifest() async {
    stdout.write(white('create manifest file..    '));

    var manifestContent = '''<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities">
  <Identity Name="${_configuration.identityName}" Version="${_configuration.msixVersion}"
            Publisher="${_configuration.certificateSubject.replaceAll(' = ', '=')}" ProcessorArchitecture="x86" />
  <Properties>
    <DisplayName>${_configuration.displayName}</DisplayName>
    <PublisherDisplayName>${_configuration.publisherName}</PublisherDisplayName>
    <Logo>${_configuration.logoPath}</Logo>
    <Description>${_configuration.appDescription}</Description>
  </Properties>
  <Resources>
    <Resource Language="en-us" />
  </Resources>
  <Dependencies>
    <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.14316.0" MaxVersionTested="10.0.15063.0" />
  </Dependencies>
  <Capabilities>
    <rescap:Capability Name="runFullTrust"/>
  </Capabilities>
  <Applications>
    <Application Id="${_configuration.appName.replaceAll('_', '')}" Executable="${_configuration.appName}.exe" EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements BackgroundColor="${_configuration.iconsBackgroundColor}" 
        DisplayName="${_configuration.displayName}" Square150x150Logo="${_configuration.tileIconPath}"
        Square44x44Logo="${_configuration.startMenuIconPath}" Description="${_configuration.appDescription}" />
    </Application>
  </Applications>
</Package>''';

    try {
      await File('${_configuration.buildFilesFolder}\\AppxManifest.xml').create()
        ..writeAsString(manifestContent);
    } catch (e) {
      throw (red('fail to create manifest file: $e'));
    }

    print(green('done!'));
  }

  Future<void> copyVCLibsFiles() async {
    stdout.write(white('copy VCLibs files..    '));

    _vCLibsFiles = await allDirectoryFiles(
        '${_configuration.vcLibsFolderPath()}/${_configuration.architecture}');

    _vCLibsFiles.forEach((file) async =>
        await File(file.path).copy('${_configuration.buildFilesFolder}/${basename(file.path)}'));

    print(green('done!'));
  }

  Future<void> cleanTemporaryFiles() async {
    stdout.write(white('cleaning temporary files..    '));

    try {
      await File('${_configuration.buildFilesFolder}/AppxManifest.xml').delete();
      await Directory('${_configuration.buildFilesFolder}/icons').delete(recursive: true);
      _vCLibsFiles.forEach((file) async =>
          await File('${_configuration.buildFilesFolder}/${basename(file.path)}').delete());
    } catch (e) {
      print(red('fail to clean temporary files from ${_configuration.buildFilesFolder}: $e'));
    }

    print(green('done!'));
  }

  Future<String> _copyIcon(String iconPath, String alternativeIconPath) async {
    iconPath = isNullOrStringNull(iconPath) ? alternativeIconPath : iconPath;
    var newPath = 'icons/${basename(iconPath)}';

    try {
      await File(iconPath).copy('${_configuration.buildFilesFolder}/$newPath');
    } catch (e) {
      throw (red('fail to create icon $iconPath: $e'));
    }

    return newPath;
  }
}
