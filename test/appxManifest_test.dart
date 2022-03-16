import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:msix/src/appxManifest.dart';
import 'package:msix/src/configuration.dart';
import 'package:test/test.dart';

const tempFolderPath = 'test/appx_manifest_temp';

void main() {
  var log = Logger.verbose();
  late Configuration config;

  setUp(() async {
    config = Configuration([], log)
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
      ..fileExtension = 'fileExtension_test'
      ..buildFilesFolder = tempFolderPath
      ..capabilities = 'location,microphone'
      ..languages = ['en-us']
      ..toastActivatorArguments = '----AppNotificationActivationServer'
      ..toastActivatorDisplayName = 'Toast activator';

    await Directory('$tempFolderPath/').create(recursive: true);
    await Future.delayed(Duration(milliseconds: 150));
  });

  tearDown(() async {
    if (await Directory('$tempFolderPath/').exists()) {
      await Future.delayed(Duration(milliseconds: 150));
      await Directory('$tempFolderPath/').delete(recursive: true);
      await Future.delayed(Duration(milliseconds: 150));
    }
  });

  test('manifest created', () async {
    await AppxManifest(config, log).generateAppxManifest();
    expect(await File('$tempFolderPath/AppxManifest.xml').exists(), true);
  });

  test('identityName is valid', () async {
    var testValue = 'identityName_test123';
    await AppxManifest(config..identityName = testValue, log)
        .generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains('<Identity Name="$testValue"'),
        true);
  });

  test('publisher is valid', () async {
    var testValue = 'publisher_test123';
    await AppxManifest(config..publisher = testValue, log)
        .generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains('Publisher="$testValue"'),
        true);
  });

  test('publisherName is valid', () async {
    var testValue = 'publisherName_test123';
    await AppxManifest(config..publisherName = testValue, log)
        .generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains(
                '<PublisherDisplayName>$testValue</PublisherDisplayName>'),
        true);
  });

  test('msixVersion is valid', () async {
    var testValue = '3.4.5.8';
    await AppxManifest(config..msixVersion = testValue, log)
        .generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains('Version="$testValue"'),
        true);
  });

  test('appName is valid', () async {
    var testValue = 'appName_test123';
    await AppxManifest(config..appName = testValue, log).generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains('Id="${testValue.replaceAll('_', '')}"'),
        true);
  });

  test('appDescription is valid', () async {
    var testValue = 'appDescription_test123';
    await AppxManifest(config..appDescription = testValue, log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
    expect(manifestContent.contains('<Description>$testValue</Description>'),
        true);
    expect(manifestContent.contains('Description="$testValue"'), true);
  });

  test('displayName is valid', () async {
    var testValue = 'displayName_test123';
    await AppxManifest(config..displayName = testValue, log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
    expect(manifestContent.contains('<DisplayName>$testValue</DisplayName>'),
        true);
    expect(manifestContent.contains('DisplayName="$testValue"'), true);
    expect(manifestContent.contains('<uap:DefaultTile ShortName="$testValue"'),
        true);
  });

  test('architecture is valid', () async {
    var testValue = 'architecture_test123';
    await AppxManifest(config..architecture = testValue, log)
        .generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains('ProcessorArchitecture="$testValue"'),
        true);
  });

  test('executableFileName is valid', () async {
    var testValue = 'executableFileName_test123';
    await AppxManifest(config..executableFileName = testValue, log)
        .generateAppxManifest();
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsLines())
            .where((line) => line.contains('Executable="$testValue"'))
            .length,
        1);
  });

  test('executableFileName with addExecutionAlias is valid', () async {
    var testValue = 'executableFileName_test123';
    await AppxManifest(
            config
              ..executableFileName = testValue
              ..executionAlias = true,
            log)
        .generateAppxManifest();

    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsLines())
            .where((line) => line.contains('Executable="$testValue"'))
            .length,
        2);
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString())
            .contains('<desktop:ExecutionAlias Alias="$testValue" />'),
        true);
  });

  test('protocolActivation is valid', () async {
    var testValue = ['protocolActivation_test123'];
    await AppxManifest(config..protocolActivation = testValue, log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
    expect(manifestContent.contains('<uap:Protocol Name="$testValue">'), true);
    expect(
        manifestContent.contains(
            '<uap:DisplayName>$testValue URI Scheme</uap:DisplayName>'),
        true);
  });

  test('fileExtension is valid', () async {
    var testValue =
        'fileExtension_test1,.fileExtension_test2,  fileExtension_test3';
    await AppxManifest(config..fileExtension = testValue, log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
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
    await AppxManifest(
            config
              ..executableFileName = testValue
              ..enableAtStartup = true,
            log)
        .generateAppxManifest();

    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsLines())
            .where((line) => line.contains('Executable="$testValue"'))
            .length,
        2);
    expect(
        (await File('$tempFolderPath/AppxManifest.xml').readAsString()).contains(
            '<desktop:Extension Category="windows.startupTask" Executable="$testValue"'),
        true);
  });
  test('capabilities is valid', () async {
    var testValue = 'videosLibrary,microphone,  documentsLibrary';
    await AppxManifest(config..capabilities = testValue, log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
    expect(manifestContent.contains('<uap:Capability Name="videosLibrary" />'),
        true);
    expect(manifestContent.contains('<DeviceCapability Name="microphone" />'),
        true);
    expect(
        manifestContent.contains('<uap:Capability Name="documentsLibrary" />'),
        true);
  });

  test('languages is valid', () async {
    await AppxManifest(config..languages = ['en-us', 'he-il'], log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
    expect(manifestContent.contains('<Resource Language="en-us" />'), true);
    expect(manifestContent.contains('<Resource Language="he-il" />'), true);
  });

  test('toast-activator-clsid is valid', () async {
    var testValue = 'c569ad1a-8a98-4512-a92c-e46fb56cf3e3';
    await AppxManifest(config..toastActivatorCLSID = testValue, log)
        .generateAppxManifest();
    var manifestContent =
        await File('$tempFolderPath/AppxManifest.xml').readAsString();
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
}
