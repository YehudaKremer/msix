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
    stdout.write(white('create icons folder..  '));

    var iconsFolderPath = '${_configuration.buildFilesFolder}\\icons';
    try {
      await Directory(iconsFolderPath).create();
    } catch (e) {
      throw (red('fail to create icons folder in $iconsFolderPath: $e'));
    }

    print(green('[√]'));
  }

  Future<void> copyIcons() async {
    stdout.write(white('copy icons..  '));

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

    print(green('[√]'));
  }

  bool hasCapability(String capability) => _configuration.capabilities
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .contains(capability.trim().toLowerCase());

  Future<void> generateAppxManifest() async {
    stdout.write(white('create manifest file..  '));

    var manifestContent = '''<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10" 
         xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10" 
         xmlns:uap2="http://schemas.microsoft.com/appx/manifest/uap/windows10/2" 
         xmlns:uap3="http://schemas.microsoft.com/appx/manifest/uap/windows10/3" 
         xmlns:uap4="http://schemas.microsoft.com/appx/manifest/uap/windows10/4" 
         xmlns:uap6="http://schemas.microsoft.com/appx/manifest/uap/windows10/6" 
         xmlns:uap7="http://schemas.microsoft.com/appx/manifest/uap/windows10/7" 
         xmlns:uap8="http://schemas.microsoft.com/appx/manifest/uap/windows10/8" 
         xmlns:uap10="http://schemas.microsoft.com/appx/manifest/uap/windows10/10" 
         xmlns:iot="http://schemas.microsoft.com/appx/manifest/iot/windows10" 
         xmlns:desktop="http://schemas.microsoft.com/appx/manifest/desktop/windows10" 
         xmlns:desktop2="http://schemas.microsoft.com/appx/manifest/desktop/windows10/2" 
         xmlns:desktop6="http://schemas.microsoft.com/appx/manifest/desktop/windows10/6" 
         xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities" 
         xmlns:rescap3="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities/3" 
         xmlns:rescap6="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities/6" 
         xmlns:com="http://schemas.microsoft.com/appx/manifest/com/windows10" 
         xmlns:com2="http://schemas.microsoft.com/appx/manifest/com/windows10/2" 
         xmlns:com3="http://schemas.microsoft.com/appx/manifest/com/windows10/3">
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
    <rescap:Capability Name="runFullTrust" />
    ${hasCapability('internetClient') ? '<Capability Name="internetClient" />' : ''}
    ${hasCapability('internetClientServer') ? '<Capability Name="internetClientServer" />' : ''}
    ${hasCapability('privateNetworkClientServer') ? '<Capability Name="privateNetworkClientServer" />' : ''}
    ${hasCapability('allJoyn') ? '<Capability Name="allJoyn" />' : ''}
    ${hasCapability('codeGeneration') ? '<Capability Name="codeGeneration" />' : ''}
    ${hasCapability('objects3D') ? '<uap:Capability Name="objects3D" />' : ''}
    ${hasCapability('chat') ? '<uap:Capability Name="chat" />' : ''}
    ${hasCapability('voipCall') ? '<uap:Capability Name="voipCall" />' : ''}
    ${hasCapability('voipCall') ? '<uap:Capability Name="voipCall" />' : ''}
    ${hasCapability('phoneCall') ? '<uap:Capability Name="phoneCall" />' : ''}
    ${hasCapability('removableStorage') ? '<uap:Capability Name="removableStorage" />' : ''}
    ${hasCapability('userAccountInformation') ? '<uap:Capability Name="userAccountInformation" />' : ''}
    ${hasCapability('sharedUserCertificates') ? '<uap:Capability Name="sharedUserCertificates" />' : ''}
    ${hasCapability('blockedChatMessages') ? '<uap:Capability Name="blockedChatMessages" />' : ''}
    ${hasCapability('appointments') ? '<uap:Capability Name="appointments" />' : ''}
    ${hasCapability('contacts') ? '<uap:Capability Name="contacts" />' : ''}
    ${hasCapability('musicLibrary') ? '<uap:Capability Name="musicLibrary" />' : ''}
    ${hasCapability('videosLibrary') ? '<uap:Capability Name="videosLibrary" />' : ''}
    ${hasCapability('picturesLibrary') ? '<uap:Capability Name="picturesLibrary" />' : ''}
    ${hasCapability('enterpriseAuthentication') ? '<uap:Capability Name="enterpriseAuthentication" />' : ''}
    ${hasCapability('phoneCallHistoryPublic') ? '<uap2:Capability Name="phoneCallHistoryPublic" />' : ''}
    ${hasCapability('spatialPerception') ? '<uap2:Capability Name="spatialPerception" />' : ''}
    ${hasCapability('userNotificationListener') ? '<uap3:Capability Name="userNotificationListener" />' : ''}
    ${hasCapability('remoteSystem') ? '<uap3:Capability Name="remoteSystem" />' : ''}
    ${hasCapability('backgroundMediaPlayback') ? '<uap3:Capability Name="backgroundMediaPlayback" />' : ''}
    ${hasCapability('offlineMapsManagement') ? '<uap4:Capability Name="offlineMapsManagement" />' : ''}
    ${hasCapability('userDataTasks') ? '<uap4:Capability Name="userDataTasks" />' : ''}
    ${hasCapability('graphicsCapture') ? '<uap6:Capability Name="graphicsCapture" />' : ''}
    ${hasCapability('globalMediaControl') ? '<uap7:Capability Name="globalMediaControl" />' : ''}
    ${hasCapability('gazeInput') ? '<uap7:Capability Name="gazeInput" />' : ''}
    ${hasCapability('systemManagement') ? '<iot:Capability Name="systemManagement" />' : ''}
    ${hasCapability('lowLevelDevices') ? '<iot:Capability Name="lowLevelDevices" />' : ''}
    ${hasCapability('documentsLibrary') ? '<rescap:Capability Name="documentsLibrary" />' : ''}
    ${hasCapability('accessoryManager') ? '<rescap:Capability Name="accessoryManager" />' : ''}
    ${hasCapability('allowElevation') ? '<rescap:Capability Name="allowElevation" />' : ''}
    ${hasCapability('location') ? '<DeviceCapability Name="location" />' : ''}
    ${hasCapability('microphone') ? '<DeviceCapability Name="microphone" />' : ''}
    ${hasCapability('webcam') ? '<DeviceCapability Name="webcam" />' : ''}
    ${hasCapability('radios') ? '<DeviceCapability Name="radios" />' : ''}
  </Capabilities>
  <Applications>
    <Application Id="${_configuration.appName.replaceAll('_', '')}" Executable="${_configuration.executableFileName}" EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements BackgroundColor="${_configuration.iconsBackgroundColor}"
        DisplayName="${_configuration.displayName}" Square150x150Logo="${_configuration.tileIconPath}"
        Square44x44Logo="${_configuration.startMenuIconPath}" Description="${_configuration.appDescription}" >
        <uap:DefaultTile ShortName="${_configuration.displayName}" Square310x310Logo="${_configuration.tileIconPath}"
        Square71x71Logo="${_configuration.startMenuIconPath}" Wide310x150Logo="${_configuration.tileIconPath}">
          <uap:ShowNameOnTiles>
            <uap:ShowOn Tile="square150x150Logo"/>
            <uap:ShowOn Tile="square310x310Logo"/>
            <uap:ShowOn Tile="wide310x150Logo"/>
          </uap:ShowNameOnTiles>
        </uap:DefaultTile>
        <uap:SplashScreen Image="${_configuration.tileIconPath}"/>
        <uap:LockScreen BadgeLogo="${_configuration.tileIconPath}" Notification="badge"/>
      </uap:VisualElements>
    </Application>
  </Applications>
</Package>''';

    try {
      await File('${_configuration.buildFilesFolder}\\AppxManifest.xml').create()
        ..writeAsString(manifestContent);
    } catch (e) {
      throw (red('fail to create manifest file: $e'));
    }

    print(green('[√]'));
  }

  Future<void> copyVCLibsFiles() async {
    stdout.write(white('copy VCLibs files..  '));

    _vCLibsFiles = await allDirectoryFiles(
        '${_configuration.vcLibsFolderPath()}/${_configuration.architecture}');

    _vCLibsFiles.forEach((file) async =>
        await File(file.path).copy('${_configuration.buildFilesFolder}/${basename(file.path)}'));

    print(green('[√]'));
  }

  Future<void> cleanTemporaryFiles() async {
    stdout.write(white('cleaning temporary files..  '));

    try {
      var appxManifest = File('${_configuration.buildFilesFolder}/AppxManifest.xml');
      if (await appxManifest.exists()) await appxManifest.delete();

      var iconsFolder = Directory('${_configuration.buildFilesFolder}/icons');
      if (await iconsFolder.exists()) await iconsFolder.delete(recursive: true);

      _vCLibsFiles.forEach((file) async {
        var fileToDelete = File('${_configuration.buildFilesFolder}/${basename(file.path)}');
        if (await fileToDelete.exists()) await fileToDelete.delete();
      });
    } catch (e) {
      print(red('fail to clean temporary files from ${_configuration.buildFilesFolder}: $e'));
    }

    print(green('[√]'));
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
