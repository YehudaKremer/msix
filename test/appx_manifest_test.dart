import 'dart:io';
import 'package:msix/src/context_menu_configuration.dart';
import 'package:path/path.dart' as p;
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/appx_manifest.dart';
import 'package:msix/src/configuration.dart';
import 'package:test/test.dart';

var tempFolderPath = p.join('test', 'runner', 'appx_manifest_temp');

void main() {
  late Configuration config;

  setUp(() async {
    GetIt.I.registerSingleton<Logger>(Logger.verbose());

    config = Configuration([])
      ..identityName = 'identityName_test'
      ..publisher = 'publisher_test'
      ..publisherName = 'publisherName_test'
      ..msixVersion = '1.2.3.0'
      ..appName = 'appName_test'
      ..appDescription = 'appDescription_test'
      ..displayName = 'displayName_test'
      ..architecture = 'x64'
      ..executableFileName = 'executableFileName_test'
      ..protocolActivation = ['protocolActivation_test']
      ..executionAlias = 'protocolActivation_test'
      ..fileExtension = 'fileExtension_test'
      ..buildFilesFolder = tempFolderPath
      ..capabilities = 'location,microphone'
      ..languages = ['en-us']
      ..toastActivatorArguments = '----AppNotificationActivationServer'
      ..toastActivatorDisplayName = 'Toast activator';

    GetIt.I.registerSingleton<Configuration>(config);

    await Directory(tempFolderPath).create(recursive: true);
  });

  tearDown(() async {
    GetIt.I.reset();

    if (await Directory(tempFolderPath).exists()) {
      await Directory(tempFolderPath).delete(recursive: true);
    }
  });

  test('manifest created', () async {
    await AppxManifest().generateAppxManifest();
    expect(
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).exists(), true);
  });

  test('identityName is valid', () async {
    var testValue = 'identityName_test123';
    config.identityName = testValue;
    await AppxManifest().generateAppxManifest();
    expect(
        (await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString())
            .contains('<Identity Name="$testValue"'),
        true);
  });

  test('publisher is valid', () async {
    var testValue = 'publisher_test123';
    config.publisher = testValue;
    await AppxManifest().generateAppxManifest();
    expect(
        (await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString())
            .contains('Publisher="$testValue"'),
        true);
  });

  test('publisherName is valid', () async {
    var testValue = 'publisherName_test123';
    config.publisherName = testValue;
    await AppxManifest().generateAppxManifest();
    expect(
        (await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString())
            .contains(
                '<PublisherDisplayName>$testValue</PublisherDisplayName>'),
        true);
  });

  test('msixVersion is valid', () async {
    var testValue = '3.4.5.8';
    config.msixVersion = testValue;
    await AppxManifest().generateAppxManifest();
    expect(
        (await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString())
            .contains('Version="$testValue"'),
        true);
  });

  test('appName is valid', () async {
    var testValue = 'appName_test123';
    config.appName = testValue;
    await AppxManifest().generateAppxManifest();
    expect(
        (await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString())
            .contains('Id="${testValue.replaceAll('_', '')}"'),
        true);
  });

  test('appDescription is valid', () async {
    var testValue = 'appDescription_test123';
    config.appDescription = testValue;
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('<Description>$testValue</Description>'),
        true);
    expect(manifestContent.contains('Description="$testValue"'), true);
  });

  test('displayName is valid', () async {
    var testValue = 'displayName_test123';
    config.displayName = testValue;
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('<DisplayName>$testValue</DisplayName>'),
        true);
    expect(manifestContent.contains('DisplayName="$testValue"'), true);
    expect(manifestContent.contains('<uap:DefaultTile ShortName="$testValue"'),
        true);
  });

  test('architecture is valid', () async {
    var testValue = 'architecture_test123';
    config.architecture = testValue;
    await AppxManifest().generateAppxManifest();
    expect(
        (await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString())
            .contains('ProcessorArchitecture="$testValue"'),
        true);
  });

  test('executableFileName is valid', () async {
    var testValue = 'executableFileName_test123';
    config.executableFileName = testValue;
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('Executable="$testValue'), true);
  });

  test('executableFileName with addExecutionAlias is valid', () async {
    var testValue = 'executableFileName_test123';
    config.executionAlias = testValue;
    await AppxManifest().generateAppxManifest();

    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(
        manifestContent.contains(
            '<desktop:ExecutionAlias Alias="${testValue.toLowerCase()}.exe" />'),
        true);
  });

  test('protocolActivation is valid', () async {
    var testValue = 'http';
    config.protocolActivation = [testValue];
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('<uap:Protocol Name="$testValue">'), true);
    expect(
        manifestContent.contains(
            '<uap:DisplayName>$testValue URI Scheme</uap:DisplayName>'),
        true);
  });

  test('fileExtension is valid', () async {
    var testValue =
        'fileExtension_test1,.fileExtension_test2,  fileExtension_test3';
    config.fileExtension = testValue;
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(
        manifestContent
            .contains('<uap:FileType>.fileExtension_test1</uap:FileType>'),
        true);
    expect(
        manifestContent
            .contains('<uap:FileType>.fileExtension_test2</uap:FileType>'),
        true);
    expect(
        manifestContent
            .contains('<uap:FileType>.fileExtension_test3</uap:FileType>'),
        true);
  });

  test('executableFileName with enableAtStartup is valid', () async {
    var testValue = 'executableFileName_test123';
    config
      ..executableFileName = testValue
      ..enableAtStartup = true;
    await AppxManifest().generateAppxManifest();

    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('Executable="$testValue'), true);
    expect(
        manifestContent.contains(
            '<desktop:Extension Category="windows.startupTask" Executable="$testValue'),
        true);
  });
  test('capabilities is valid', () async {
    var testValue = 'videosLibrary,microphone,  documentsLibrary';
    config.capabilities = testValue;
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('<uap:Capability Name="videosLibrary" />'),
        true);
    expect(manifestContent.contains('<DeviceCapability Name="microphone" />'),
        true);
    expect(
        manifestContent.contains('<uap:Capability Name="documentsLibrary" />'),
        true);
  });

  test('languages is valid', () async {
    config.languages = ['en-us', 'he-il'];
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(manifestContent.contains('<Resource Language="en-us" />'), true);
    expect(manifestContent.contains('<Resource Language="he-il" />'), true);
  });

  test('toast-activator-clsid is valid', () async {
    var testValue = 'c569ad1a-8a98-4512-a92c-e46fb56cf3e3';
    config.toastActivatorCLSID = testValue;
    await AppxManifest().generateAppxManifest();
    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();
    expect(
        manifestContent.contains(
            '<com:ExeServer Executable="executableFileName_test" Arguments="----AppNotificationActivationServer" DisplayName="Toast activator">'),
        true);
    expect(
        manifestContent.contains(
            '<desktop:ToastNotificationActivation ToastActivatorCLSID="$testValue"/>'),
        true);
    expect(manifestContent.contains('<com:Class Id="$testValue"/>'), true);
  });

  test('context-menu is valid', () async {
    var testGuid = 'ba40803c-736a-41f0-ba7c-cdb3eaed7496';
    var testGuid2 = 'ba40803c-736a-41f0-ba7c-cdb3eaed7497';

    config.contextMenuConfiguration =
        ContextMenuConfiguration(dllPath: 'test_dll.dll', items: [
      ContextMenuItem(
        type: '*',
        commands: [
          ContextMenuItemCommand(id: 'test1', clsid: testGuid),
        ],
      ),
      ContextMenuItem(
        type: 'Directory',
        commands: [
          ContextMenuItemCommand(id: 'test1', clsid: testGuid),
        ],
      ),
      ContextMenuItem(
        type: 'Directory\\Background',
        commands: [
          ContextMenuItemCommand(
              id: 'test2', clsid: testGuid2, customDllPath: 'test_dll2.dll'),
        ],
      ),
    ]);

    await AppxManifest().generateAppxManifest();

    var manifestContent =
        await File(p.join(tempFolderPath, 'AppxManifest.xml')).readAsString();

    expect(
      manifestContent,
      stringContainsInOrder(
        config.contextMenuConfiguration!.items.map((e) {
          return '''<desktop5:ItemType Type="${e.type}">
                  ${e.commands.map((e) => '''<desktop5:Verb Id="${e.id}" Clsid="${e.clsid}" />''').join('\n')}
                </desktop5:ItemType>''';
        }).toList(),
      ),
    );

    expect(
      manifestContent,
      stringContainsInOrder(
        config.contextMenuConfiguration!.comSurrogateServers.map((e) {
          return '<com:Class Id="${e.clsid}" Path="${p.basename(e.dllPath)}" ThreadingModel="STA"/>';
        }).toList(),
      ),
    );
  });
}
