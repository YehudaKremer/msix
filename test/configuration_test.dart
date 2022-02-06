import 'dart:io';
import 'package:cli_util/cli_logging.dart';
import 'package:msix/src/configuration.dart';
import 'package:test/test.dart';

const tempFolderPath = 'test/configuration_temp';
const yamlTestPath = '$tempFolderPath/test.yaml';

void main() {
  var log = Logger.verbose();
  late Configuration config;
  const yamlContent = '''

name: testAppName

msix_config:  
  ''';

  setUp(() async {
    config = Configuration([], log)
      ..pubspecYamlPath = yamlTestPath
      ..buildFilesFolder = tempFolderPath;

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

  group('app name:', () {
    test('valid app name', () async {
      await File(yamlTestPath).writeAsString('name: testAppName123');
      await config.getConfigValues();
      expect(config.appName, 'testAppName123');
    });

    test('with out app name', () async {
      await File(yamlTestPath).writeAsString('name:');
      expect(() async => await config.getConfigValues(), throwsException);
    });

    test('with out app name property', () async {
      await File(yamlTestPath).writeAsString('description:');
      expect(() async => await config.getConfigValues(), throwsException);
    });
  });

  test('valid description', () async {
    await File(yamlTestPath)
        .writeAsString('description: description123' + yamlContent);
    await config.getConfigValues();
    expect(config.appDescription, 'description123');
  });

  group('msix version:', () {
    test('valid version in yaml', () async {
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'msix_version: 1.2.3.4');
      await config.getConfigValues();
      expect(config.msixVersion, '1.2.3.4');
    });

    test('invalid version letter in yaml', () async {
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'msix_version: 1.s.3.4');
      expect(() async => await config.getConfigValues(), throwsException);
    });

    test('invalid version space in yaml', () async {
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'msix_version: 1.s. 3.4');
      expect(() async => await config.getConfigValues(), throwsException);
    });

    test('valid version in long argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      var customConfig = Configuration(['--version', '1.2.3.4'], log)
        ..pubspecYamlPath = yamlTestPath
        ..buildFilesFolder = tempFolderPath;
      await customConfig.getConfigValues();
      expect(config.msixVersion, '1.2.3.4');
    });

    test('invalid version letter in long argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      var customConfig = Configuration(['--version', '1.s.3.4'], log)
        ..pubspecYamlPath = yamlTestPath
        ..buildFilesFolder = tempFolderPath;
      expect(() async => await customConfig.getConfigValues(), throwsException);
    });

    test('valid version in short argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      var customConfig = Configuration(['-v', '1.2.3.4'], log)
        ..pubspecYamlPath = yamlTestPath
        ..buildFilesFolder = tempFolderPath;
      await customConfig.getConfigValues();
      expect(config.msixVersion, '1.2.3.4');
    });
  });

  group('certificate:', () {
    test('exited certificate path with password', () async {
      const pfxTestPath = '$tempFolderPath/test.pfx';
      await File(pfxTestPath).create();
      await File(yamlTestPath).writeAsString(yamlContent +
          '''certificate_path: $pfxTestPath  
  certificate_password: 1234''');
      await config.getConfigValues();
      expect(config.certificatePath, pfxTestPath);
    });

    test('invalid certificate path', () async {
      await File(yamlTestPath).writeAsString(
          yamlContent + 'certificate_path: $tempFolderPath/test123.pfx');
      expect(() async => await config.getConfigValues(), throwsException);
    });

    test('certificate without password', () async {
      const pfxTestPath = '$tempFolderPath/test.pfx';
      await File(pfxTestPath).create();
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'certificate_path: $pfxTestPath');
      expect(() async => await config.getConfigValues(), throwsException);
    });
  });
}
