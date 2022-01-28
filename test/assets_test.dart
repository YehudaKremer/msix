import 'dart:io';

import 'package:image/image.dart';
import 'package:msix/src/assets.dart';
import 'package:msix/src/configuration.dart';
import 'package:msix/src/log.dart';
import 'package:test/test.dart';

const tempFolderPath = 'test/assets_temp';

void main() {
  var log = Log();
  late Configuration config;

  setUp(() async {
    config = Configuration(log)
      ..identityName = 'identityName_test'
      ..publisher = 'publisher_test'
      ..publisherName = 'publisherName_test'
      ..msixVersion = '1.2.3.0'
      ..appName = 'appName_test'
      ..appDescription = 'appDescription_test'
      ..displayName = 'displayName_test'
      ..architecture = 'x64'
      ..executableFileName = 'executableFileName_test'
      ..protocolActivation = 'protocolActivation_test'
      ..fileExtension = 'fileExtension_test'
      ..buildFilesFolder = tempFolderPath
      ..capabilities = 'location,microphone'
      ..languages = ['en-us'];

    await Directory('$tempFolderPath/').create(recursive: true);
    await Future.delayed(Duration(milliseconds: 100));
  });

  tearDown(() async {
    await Directory('$tempFolderPath/').delete(recursive: true);
    await Future.delayed(Duration(milliseconds: 100));
  });

  test('copy assets folder', () async {
    const folderNameTest = 'folder_name_test';
    const sourceFolder = '$tempFolderPath/source/$folderNameTest/';
    await File('$sourceFolder/test1.txt').create(recursive: true);
    await File('$sourceFolder/test2.txt').create(recursive: true);
    await File('$sourceFolder/subFolder/test3.txt').create(recursive: true);

    Assets(config..assetsFolderPath = sourceFolder, log).copyAssetsFolder();
    expect(
        await File('$tempFolderPath/$folderNameTest/test1.txt').exists(), true);
    expect(
        await File('$tempFolderPath/$folderNameTest/test2.txt').exists(), true);
    expect(
        await File('$tempFolderPath/$folderNameTest/subFolder/test3.txt')
            .exists(),
        true);
  });

  test('create icons folder', () async {
    await Assets(config..msixAssetsPath = tempFolderPath, log)
        .createIconsFolder();
    expect(await Directory('$tempFolderPath/Images').exists(), true);
  });

  test('copy defaults icons', () async {
    await File('$tempFolderPath/icons/test1.png').create(recursive: true);
    await File('$tempFolderPath/icons/test2.png').create(recursive: true);
    await Directory('$tempFolderPath/Images').create(recursive: true);

    await Assets(config..msixAssetsPath = tempFolderPath, log).copyIcons();
    expect(await File('$tempFolderPath/Images/test1.png').exists(), true);
    expect(await File('$tempFolderPath/Images/test2.png').exists(), true);
  });

  test('generate icons (expect 82 new images)', () async {
    Image image = Image(320, 240);
    fill(image, getColor(0, 0, 255));
    await File('$tempFolderPath/test.png').writeAsBytes(encodePng(image));
    await Directory('$tempFolderPath/Images').create(recursive: true);
    await Assets(config..logoPath = '$tempFolderPath/test.png', log)
        .copyIcons();
    expect(
        (await Directory('$tempFolderPath/Images').list().toList()).length, 82);
  });

  test('copy vclibs files', () async {
    const vclibsFolderPath = '$tempFolderPath/VCLibs/x86/';
    await File('$vclibsFolderPath/msvcp140.dll').create(recursive: true);
    await File('$vclibsFolderPath/vcruntime140_1.dll').create(recursive: true);
    await File('$vclibsFolderPath/vcruntime140.dll').create(recursive: true);

    await Assets(
            config
              ..msixAssetsPath = tempFolderPath
              ..architecture = 'x86',
            log)
        .copyVCLibsFiles();
    expect(await File('$vclibsFolderPath/msvcp140.dll').exists(), true);
    expect(await File('$vclibsFolderPath/vcruntime140_1.dll').exists(), true);
    expect(await File('$vclibsFolderPath/vcruntime140.dll').exists(), true);
  });

  test('clean temporary files', () async {
    await File('$tempFolderPath/resources.scale-125.pri').create();
    await File('$tempFolderPath/test.msix').create();
    await Directory('$tempFolderPath/Images').create();
    await Directory('$tempFolderPath/VCLibs/x64/').create(recursive: true);

    await Assets(
            config
              ..msixAssetsPath = tempFolderPath
              ..architecture = 'x64',
            log)
        .cleanTemporaryFiles(clearMsixFiles: false);
    expect(
        await File('$tempFolderPath/resources.scale-125.pri').exists(), false);
    expect(await File('$tempFolderPath/test.msix').exists(), true);
    expect(await Directory('$tempFolderPath/Images').exists(), false);

    await Assets(config, log).cleanTemporaryFiles(clearMsixFiles: true);
    expect(await File('$tempFolderPath/test.msix').exists(), false);
  });
}
