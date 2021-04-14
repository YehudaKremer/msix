import 'dart:io';
import 'log.dart';
import 'extensions.dart';
import 'configuration.dart';

class Manifest {
  Configuration _config;

  Manifest(this._config);

  void generateAppxManifest() {
    Log.startTask('generate appx manifest');

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
    <Identity Name="${_config.identityName}" Version="${_config.msixVersion}"
              Publisher="${_config.publisher!.replaceAll(' = ', '=')}" ProcessorArchitecture="${_config.architecture}" />
    <Properties>
      <DisplayName>${_config.displayName}</DisplayName>
      <PublisherDisplayName>${_config.publisherName}</PublisherDisplayName>
      ${_getLogo()}
      <Description>${_config.appDescription}</Description>
    </Properties>
    <Resources>
      ${_config.languages!.map((language) => '<Resource Language="$language" />').join('')}
    </Resources>
    <Dependencies>
      <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.17763.0" MaxVersionTested="10.0.19042.630" />
    </Dependencies>
    <Capabilities>
      <rescap:Capability Name="runFullTrust" />
      ${_hasCapability('internetClient') ? '<Capability Name="internetClient" />' : ''}
      ${_hasCapability('internetClientServer') ? '<Capability Name="internetClientServer" />' : ''}
      ${_hasCapability('privateNetworkClientServer') ? '<Capability Name="privateNetworkClientServer" />' : ''}
      ${_hasCapability('allJoyn') ? '<Capability Name="allJoyn" />' : ''}
      ${_hasCapability('codeGeneration') ? '<Capability Name="codeGeneration" />' : ''}
      ${_hasCapability('objects3D') ? '<uap:Capability Name="objects3D" />' : ''}
      ${_hasCapability('chat') ? '<uap:Capability Name="chat" />' : ''}
      ${_hasCapability('voipCall') ? '<uap:Capability Name="voipCall" />' : ''}
      ${_hasCapability('phoneCall') ? '<uap:Capability Name="phoneCall" />' : ''}
      ${_hasCapability('removableStorage') ? '<uap:Capability Name="removableStorage" />' : ''}
      ${_hasCapability('userAccountInformation') ? '<uap:Capability Name="userAccountInformation" />' : ''}
      ${_hasCapability('sharedUserCertificates') ? '<uap:Capability Name="sharedUserCertificates" />' : ''}
      ${_hasCapability('blockedChatMessages') ? '<uap:Capability Name="blockedChatMessages" />' : ''}
      ${_hasCapability('appointments') ? '<uap:Capability Name="appointments" />' : ''}
      ${_hasCapability('contacts') ? '<uap:Capability Name="contacts" />' : ''}
      ${_hasCapability('musicLibrary') ? '<uap:Capability Name="musicLibrary" />' : ''}
      ${_hasCapability('videosLibrary') ? '<uap:Capability Name="videosLibrary" />' : ''}
      ${_hasCapability('picturesLibrary') ? '<uap:Capability Name="picturesLibrary" />' : ''}
      ${_hasCapability('enterpriseAuthentication') ? '<uap:Capability Name="enterpriseAuthentication" />' : ''}
      ${_hasCapability('phoneCallHistoryPublic') ? '<uap2:Capability Name="phoneCallHistoryPublic" />' : ''}
      ${_hasCapability('spatialPerception') ? '<uap2:Capability Name="spatialPerception" />' : ''}
      ${_hasCapability('userNotificationListener') ? '<uap3:Capability Name="userNotificationListener" />' : ''}
      ${_hasCapability('remoteSystem') ? '<uap3:Capability Name="remoteSystem" />' : ''}
      ${_hasCapability('backgroundMediaPlayback') ? '<uap3:Capability Name="backgroundMediaPlayback" />' : ''}
      ${_hasCapability('offlineMapsManagement') ? '<uap4:Capability Name="offlineMapsManagement" />' : ''}
      ${_hasCapability('userDataTasks') ? '<uap4:Capability Name="userDataTasks" />' : ''}
      ${_hasCapability('graphicsCapture') ? '<uap6:Capability Name="graphicsCapture" />' : ''}
      ${_hasCapability('globalMediaControl') ? '<uap7:Capability Name="globalMediaControl" />' : ''}
      ${_hasCapability('gazeInput') ? '<uap7:Capability Name="gazeInput" />' : ''}
      ${_hasCapability('systemManagement') ? '<iot:Capability Name="systemManagement" />' : ''}
      ${_hasCapability('lowLevelDevices') ? '<iot:Capability Name="lowLevelDevices" />' : ''}
      ${_hasCapability('documentsLibrary') ? '<rescap:Capability Name="documentsLibrary" />' : ''}
      ${_hasCapability('accessoryManager') ? '<rescap:Capability Name="accessoryManager" />' : ''}
      ${_hasCapability('allowElevation') ? '<rescap:Capability Name="allowElevation" />' : ''}
      ${_hasCapability('location') ? '<DeviceCapability Name="location" />' : ''}
      ${_hasCapability('microphone') ? '<DeviceCapability Name="microphone" />' : ''}
      ${_hasCapability('webcam') ? '<DeviceCapability Name="webcam" />' : ''}
      ${_hasCapability('radios') ? '<DeviceCapability Name="radios" />' : ''}
    </Capabilities>
    <Applications>
      <Application Id="${_config.appName!.replaceAll('_', '')}" Executable="${_config.executableFileName}" EntryPoint="Windows.FullTrustApplication">
        ${_getVisualElements()}
      </Application>
    </Applications>
  </Package>''';

    //clear empty rows
    manifestContent = manifestContent.replaceAll('    \n', '');

    var appxManifestPath = '${_config.buildFilesFolder}\\AppxManifest.xml';
    try {
      File(appxManifestPath).createSync();
      File(appxManifestPath).writeAsStringSync(manifestContent);
    } catch (e) {
      Log.error('fail to create manifest file: $e');
      exit(0);
    }

    Log.completeTask();
  }

  String _getVisualElements() {
    if (_config.vsGeneratedImagesFolderPath.isNull) {
      return '''<uap:VisualElements BackgroundColor="${_config.iconsBackgroundColor}"
        DisplayName="${_config.displayName}" Square150x150Logo="${_config.tileIconPath}"
        Square44x44Logo="${_config.startMenuIconPath}" Description="${_config.appDescription}" >
        <uap:DefaultTile ShortName="${_config.displayName}" Square310x310Logo="${_config.tileIconPath}"
        Square71x71Logo="${_config.startMenuIconPath}" Wide310x150Logo="${_config.tileIconPath}">
          <uap:ShowNameOnTiles>
            <uap:ShowOn Tile="square150x150Logo"/>
            <uap:ShowOn Tile="square310x310Logo"/>
            <uap:ShowOn Tile="wide310x150Logo"/>
          </uap:ShowNameOnTiles>
        </uap:DefaultTile>
        <uap:SplashScreen Image="${_config.tileIconPath}"/>
        <uap:LockScreen BadgeLogo="${_config.tileIconPath}" Notification="badge"/>
      </uap:VisualElements>''';
    } else {
      return '''<uap:VisualElements BackgroundColor="${_config.iconsBackgroundColor}"
        DisplayName="${_config.displayName}" Square150x150Logo="Images\\Square150x150Logo.png"
        Square44x44Logo="Images\\Square44x44Logo.png" Description="${_config.appDescription}" >
        <uap:DefaultTile ShortName="${_config.displayName}" Square310x310Logo="Images\\LargeTile.png"
        Square71x71Logo="Images\\SmallTile.png" Wide310x150Logo="Images\\Wide310x150Logo.png">
          <uap:ShowNameOnTiles>
            <uap:ShowOn Tile="square150x150Logo"/>
            <uap:ShowOn Tile="square310x310Logo"/>
            <uap:ShowOn Tile="wide310x150Logo"/>
          </uap:ShowNameOnTiles>
        </uap:DefaultTile>
        <uap:SplashScreen Image="Images\\SplashScreen.png"/>
        <uap:LockScreen BadgeLogo="Images\\BadgeLogo.png" Notification="badge"/>
      </uap:VisualElements>''';
    }
  }

  String _getLogo() {
    if (_config.vsGeneratedImagesFolderPath.isNull) {
      return '''<Logo>${_config.logoPath}</Logo>''';
    } else {
      return '<Logo>Images\\StoreLogo.png</Logo>';
    }
  }

  bool _hasCapability(String capability) => _config.capabilities!
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .contains(capability.trim().toLowerCase());
}
