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

    var iconsFolderPath =
        '${_configuration.buildFilesFolder}\\$iconsFolderName';
    try {
      await Directory(iconsFolderPath).create();
    } catch (e) {
      throw (red('fail to create icons folder in $iconsFolderPath: $e'));
    }

    print(green('done!'));
  }

  Future<void> createIcons() async {
    stdout.write(white('copy icons..    '));

    try {
      _configuration.logoPath = await _copyIcon(
          !isNullOrStringNull(_configuration.logoPath)
              ? _configuration.logoPath
              : File('${defaultsIconsFolderPath()}/icon.png').path);
    } catch (e) {
      throw (red('fail to create icon ${_configuration.logoPath}: $e'));
    }

    try {
      _configuration.startMenuIconPath = await _copyIcon(
          !isNullOrStringNull(_configuration.startMenuIconPath)
              ? _configuration.startMenuIconPath
              : File('${defaultsIconsFolderPath()}/44_44.png').path);
    } catch (e) {
      throw (red(
          'fail to create icon ${_configuration.startMenuIconPath}: $e'));
    }

    try {
      _configuration.tileIconPath = await _copyIcon(
          !isNullOrStringNull(_configuration.tileIconPath)
              ? _configuration.tileIconPath
              : File('${defaultsIconsFolderPath()}/150_150.png').path);
    } catch (e) {
      throw (red('fail to create icon ${_configuration.tileIconPath}: $e'));
    }

    print(green('done!'));
  }

  Future<void> generateAppxManifest() async {
    stdout.write(white('create manifest file..    '));

    try {
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

      var manifestFile =
          await File('${_configuration.buildFilesFolder}\\AppxManifest.xml')
              .create();
      await manifestFile.writeAsString(manifestContent);
    } catch (e) {
      throw (red('fail to create manifest file: $e'));
    }

    print(green('done!'));
  }

  Future<void> copyVCLibsFiles() async {
    stdout.write(white('copy VCLibs files..    '));

    _vCLibsFiles = await allDirectoryFiles(
        '${vcLibsFolderPath()}/${_configuration.architecture == 'x86' ? 'x86' : 'x64'}');

    _vCLibsFiles.forEach((file) async {
      await File(file.path)
          .copy('${_configuration.buildFilesFolder}/${basename(file.path)}');
    });

    print(green('done!'));
  }

  Future<void> cleanTemporaryFiles() async {
    stdout.write(white('cleaning temporary files..    '));

    try {
      await File('${_configuration.buildFilesFolder}/AppxManifest.xml')
          .delete();
      await Directory('${_configuration.buildFilesFolder}/$iconsFolderName')
          .delete(recursive: true);

      _vCLibsFiles.forEach((file) async {
        await File('${_configuration.buildFilesFolder}/${basename(file.path)}')
            .delete();
      });
    } catch (e) {
      print(red(
          'fail to clean temporary files from ${_configuration.buildFilesFolder}: $e'));
    }

    print(green('done!'));
  }

  Future<String> _copyIcon(String iconPath) async {
    var newPath = '$iconsFolderName/${basename(iconPath)}';
    await File(iconPath).copy('${_configuration.buildFilesFolder}/$newPath');
    return newPath;
  }
}
