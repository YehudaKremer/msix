import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart';
import 'package:msix/src/assets.dart';
import 'package:msix/src/configuration.dart';
import 'package:test/test.dart';

const tempFolderPath = 'test/assets_temp';

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
      ..fileExtension = 'fileExtension_test'
      ..buildFilesFolder = tempFolderPath
      ..capabilities = 'location,microphone'
      ..languages = ['en-us'];

    GetIt.I.registerSingleton<Configuration>(config);

    await Directory('$tempFolderPath/').create(recursive: true);
  });

  tearDown(() async {
    GetIt.I.reset();

    if (await Directory('$tempFolderPath/').exists()) {
      await Directory('$tempFolderPath/').delete(recursive: true);
    }
  });
  test('copy defaults icons', () async {
    await File('$tempFolderPath/icons/test1.png').create(recursive: true);
    await File('$tempFolderPath/icons/test2.png').create(recursive: true);
    await Directory('$tempFolderPath/Images').create(recursive: true);
    config.msixAssetsPath = tempFolderPath;
    await Assets().createIcons();
    expect(await File('$tempFolderPath/Images/test1.png').exists(), true);
    expect(await File('$tempFolderPath/Images/test2.png').exists(), true);
  });

  test('generate icons (expect 82 new images)', () async {
    Image image = Image(width: 320, height: 240);
    fill(image, color: ColorRgb8(0, 0, 255));
    await File('$tempFolderPath/test.png').writeAsBytes(encodePng(image));
    await Directory('$tempFolderPath/Images').create(recursive: true);
    await Future.delayed(const Duration(milliseconds: 200));
    config.logoPath = '$tempFolderPath/test.png';
    await Assets().createIcons();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(
        (await Directory('$tempFolderPath/Images').list().toList()).length, 82);
    await Future.delayed(const Duration(milliseconds: 100));
  });

  test('copy vclibs files', () async {
    const vclibsFolderPath = '$tempFolderPath/VCLibs/x86/';
    await File('$vclibsFolderPath/msvcp140.dll').create(recursive: true);
    await File('$vclibsFolderPath/vcruntime140_1.dll').create(recursive: true);
    await File('$vclibsFolderPath/vcruntime140.dll').create(recursive: true);
    await Future.delayed(const Duration(milliseconds: 100));
    config
      ..msixAssetsPath = tempFolderPath
      ..architecture = 'x86';
    await Assets().copyVCLibsFiles();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(await File('$vclibsFolderPath/msvcp140.dll').exists(), true);
    expect(await File('$vclibsFolderPath/vcruntime140_1.dll').exists(), true);
    expect(await File('$vclibsFolderPath/vcruntime140.dll').exists(), true);
  });

  test('clean temporary files', () async {
    await File('$tempFolderPath/resources.scale-125.pri').create();
    await File('$tempFolderPath/test.msix').create();
    await Directory('$tempFolderPath/Images').create();
    await Directory('$tempFolderPath/VCLibs/x64/').create(recursive: true);
    await Future.delayed(const Duration(milliseconds: 100));
    config
      ..msixAssetsPath = tempFolderPath
      ..architecture = 'x64';
    await Assets().cleanTemporaryFiles(clearMsixFiles: false);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(
        await File('$tempFolderPath/resources.scale-125.pri').exists(), false);
    expect(await File('$tempFolderPath/test.msix').exists(), true);
    expect(await Directory('$tempFolderPath/Images').exists(), false);

    await Assets().cleanTemporaryFiles(clearMsixFiles: true);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(await File('$tempFolderPath/test.msix').exists(), false);
  });
}
