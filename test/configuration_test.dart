import 'dart:io';
import 'package:msix/src/configuration.dart';
import 'package:msix/src/log.dart';
import 'package:test/test.dart';

const tempFolderPath = 'test/configuration_temp';
const yamlTestPath = '$tempFolderPath/test.yaml';

void main() {
  var log = Log();
  late Configuration config;
  const yamlContent = '''

name: testAppName

msix_config:  
  ''';

  setUp(() async {
    config = Configuration(log)
      ..pubspecYamlPath = yamlTestPath
      ..buildFilesFolder = tempFolderPath;

    await Directory('$tempFolderPath/').create(recursive: true);
    await Future.delayed(Duration(milliseconds: 100));
  });

  tearDown(() async {
    await Directory('$tempFolderPath/').delete(recursive: true);
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('app name:', () {
    test('valid app name', () async {
      await File(yamlTestPath).writeAsString('name: testAppName123');
      await config.getConfigValues([]);
      expect(config.appName, 'testAppName123');
    });

    test('with out app name', () async {
      await File(yamlTestPath).writeAsString('name:');
      expect(() async => await config.getConfigValues([]),
          throwsA(isA<AppNameException>()));
    });

    test('with out app name property', () async {
      await File(yamlTestPath).writeAsString('description:');
      expect(() async => await config.getConfigValues([]),
          throwsA(isA<AppNameException>()));
    });
  });

  test('valid description', () async {
    await File(yamlTestPath)
        .writeAsString('description: description123' + yamlContent);
    await config.getConfigValues([]);
    expect(config.appDescription, 'description123');
  });

  group('msix version:', () {
    test('valid version in yaml', () async {
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'msix_version: 1.2.3.4');
      await config.getConfigValues([]);
      expect(config.msixVersion, '1.2.3.4');
    });

    test('invalid version letter in yaml', () async {
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'msix_version: 1.s.3.4');
      expect(() async => await config.getConfigValues([]),
          throwsA(isA<VersionException>()));
    });

    test('invalid version space in yaml', () async {
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'msix_version: 1.s. 3.4');
      expect(() async => await config.getConfigValues([]),
          throwsA(isA<VersionException>()));
    });

    test('valid version in long argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      await config.getConfigValues(['--version', '1.2.3.4']);
      expect(config.msixVersion, '1.2.3.4');
    });

    test('invalid version letter in long argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      expect(() async => await config.getConfigValues(['--version', '1.s.3.4']),
          throwsA(isA<VersionException>()));
    });

    test('valid version in short argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      await config.getConfigValues(['-v', '1.2.3.4']);
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
      await config.getConfigValues([]);
      expect(config.certificatePath, pfxTestPath);
    });

    test('invalid certificate path', () async {
      await File(yamlTestPath).writeAsString(
          yamlContent + 'certificate_path: $tempFolderPath/test123.pfx');
      expect(() async => await config.getConfigValues([]),
          throwsA(isA<CertificateException>()));
    });

    test('certificate without password', () async {
      const pfxTestPath = '$tempFolderPath/test.pfx';
      await File(pfxTestPath).create();
      await File(yamlTestPath)
          .writeAsString(yamlContent + 'certificate_path: $pfxTestPath');
      expect(() async => await config.getConfigValues([]),
          throwsA(isA<CertificatePasswordException>()));
    });
  });
}
