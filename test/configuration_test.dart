import 'dart:io';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/configuration.dart';
import 'package:test/test.dart';

import 'utils/version_test_case.dart';

const tempFolderPath = 'test/configuration_temp';
const yamlTestPath = '$tempFolderPath/test.yaml';

void main() {
  late Configuration config;
  const yamlContent = '''

name: testAppName

msix_config:  
  ''';

  setUp(() async {
    GetIt.I.registerSingleton<Logger>(Logger.verbose());

    config = Configuration([])
      ..pubspecYamlPath = yamlTestPath
      ..buildFilesFolder = tempFolderPath;

    GetIt.I.registerSingleton<Configuration>(config);

    await Directory('$tempFolderPath/').create(recursive: true);
  });

  tearDown(() async {
    GetIt.I.reset();

    if (await Directory('$tempFolderPath/').exists()) {
      await Directory('$tempFolderPath/').delete(recursive: true);
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
      await config.getConfigValues();
      await expectLater(
          config.validateConfigValues,
          throwsA(predicate(
              (String error) => error.contains('App name is empty'))));
    });

    test('with out app name property', () async {
      await File(yamlTestPath).writeAsString('description:');
      await config.getConfigValues();
      await expectLater(
          config.validateConfigValues,
          throwsA(predicate(
              (String error) => error.contains('App name is empty'))));
    });
  });

  test('valid description', () async {
    await File(yamlTestPath)
        .writeAsString('description: description123$yamlContent');
    await config.getConfigValues();
    expect(config.appDescription, 'description123');
  });

  group('msix version:', () {
    test('valid version in yaml', () async {
      await File(yamlTestPath)
          .writeAsString('${yamlContent}msix_version: 1.2.3.4');
      await config.getConfigValues();
      expect(config.msixVersion, '1.2.3.4');
    });

    test('invalid version letter in yaml', () async {
      await File(yamlTestPath)
          .writeAsString('${yamlContent}msix_version: 1.s.3.4');
      await config.getConfigValues();
      await expectLater(
          config.validateConfigValues,
          throwsA(predicate((String error) =>
              error.contains('msix version can be only in this format'))));
    });

    test('invalid version space in yaml', () async {
      await File(yamlTestPath)
          .writeAsString('${yamlContent}msix_version: 1.s. 3.4');
      await config.getConfigValues();
      await expectLater(
          config.validateConfigValues,
          throwsA(predicate((String error) =>
              error.contains('msix version can be only in this format'))));
    });

    test('valid version in long argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      var customConfig = Configuration(['--version', '1.2.3.4'])
        ..pubspecYamlPath = yamlTestPath
        ..buildFilesFolder = tempFolderPath;
      await customConfig.getConfigValues();
      expect(customConfig.msixVersion, '1.2.3.4');
    });

    test('invalid version letter in long argument', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      var customConfig = Configuration(['--version', '1.s.3.4'])
        ..pubspecYamlPath = yamlTestPath
        ..buildFilesFolder = tempFolderPath;
      await customConfig.getConfigValues();
      await expectLater(
          customConfig.validateConfigValues,
          throwsA(predicate((String error) =>
              error.contains('msix version can be only in this format'))));
    });

    test('setting version with old -v options', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      var customConfig = Configuration(['-v', '1.2.3.4'])
        ..pubspecYamlPath = yamlTestPath
        ..buildFilesFolder = tempFolderPath;
      await customConfig.getConfigValues();
      expect(config.msixVersion, isNull);
    });

    test('fallback to pubspec version', () async {
      await File(yamlTestPath).writeAsString(
        'name: testAppWithVersion\n'
        'version: 1.2.3',
      );
      await config.getConfigValues();
      expect(config.msixVersion, equals('1.2.3.0'));
    });
    test('pubspec with buildnumber', () async {
      await File(yamlTestPath).writeAsString(
        'name: testAppWithVersion\n'
        'version: 1.2.3+45',
      );
      await config.getConfigValues();
      expect(config.msixVersion, equals('1.2.3.0'));
    });
    group("versionWithBuildNumber:", () {
      const _testList = <VersionTestCase>[
        VersionTestCase(
          testName: "normal version",
          versionString: "1.2.3+4",
          versionWithBuildNumber: false,
          result: "1.2.3.0",
        ),
        VersionTestCase(
          testName: "normal version",
          versionString: "1.2.3+4",
          versionWithBuildNumber: true,
          result: "1.203.4.0",
        ),
        VersionTestCase(
          testName: "maximum major version",
          versionString: "65535.2.3+4",
          versionWithBuildNumber: true,
          result: "65535.203.4.0",
        ),
        VersionTestCase(
          testName: "major version too high",
          versionString: "65536.2.3+4",
          versionWithBuildNumber: true,
          result: null,
        ),
        VersionTestCase(
          testName: "maximum minor version",
          versionString: "5.654.0+0",
          versionWithBuildNumber: true,
          result: "5.65400.0.0",
        ),
        VersionTestCase(
          testName: "minor version too high",
          versionString: "5.655.0+0",
          versionWithBuildNumber: true,
          result: null,
        ),
        VersionTestCase(
          testName: "maximum minor version",
          versionString: "5.6.99+0",
          versionWithBuildNumber: true,
          result: "5.699.0.0",
        ),
        VersionTestCase(
          testName: " minor version too high",
          versionString: "5.6.100+0",
          versionWithBuildNumber: true,
          result: null,
        ),
        VersionTestCase(
          testName: "maximum build version",
          versionString: "5.6.7+65535",
          versionWithBuildNumber: true,
          result: "5.607.65535.0",
        ),
        VersionTestCase(
          testName: "build version too high",
          versionString: "5.6.7+65536",
          versionWithBuildNumber: true,
          result: null,
        ),
        VersionTestCase(
          testName: "invalid buildVersion",
          versionString: "5.6.7+a",
          versionWithBuildNumber: true,
          result: null,
        ),
        VersionTestCase(
          testName: "from msix_version example",
          versionString: "1.2.13+35",
          versionWithBuildNumber: true,
          result: "1.213.35.0",
        )
      ];
      for (final testCase in _testList) {
        test(testCase.testName, () async {
          await File(yamlTestPath).writeAsString('name: testAppWithVersion\n'
              'version: ${testCase.versionString}\n'
              'msix_config:\n'
              '  version_with_build_number: ${testCase.versionWithBuildNumber}');
          await config.getConfigValues();
          expect(config.msixVersion, equals(testCase.result));
        });
      }
    });
    test('ignores extra semver info in pubspec version', () async {
      await File(yamlTestPath).writeAsString(
        'name: testAppWithVersion\n'
        'version: 0.8.13-alpha.1+2000-01-01',
      );
      await config.getConfigValues();
      expect(config.msixVersion, equals('0.8.13.0'));
    });

    test('puts version null on invalid semver', () async {
      await File(yamlTestPath).writeAsString(
        'name: invalidSemverApp\n'
        'version: 0.8.13a',
      );
      await config.getConfigValues();
      expect(config.msixVersion, isNull);
    });

    test('no version provided - null then maps to 1.0.0.0', () async {
      await File(yamlTestPath).writeAsString(yamlContent);
      await config.getConfigValues();
      expect(config.msixVersion, isNull);
      await config.validateConfigValues();
      expect(config.msixVersion, equals('1.0.0.0'));
    });
  });

  group('certificate:', () {
    test('exited certificate path with password', () async {
      const pfxTestPath = '$tempFolderPath/test.pfx';
      await File(pfxTestPath).create();
      await File(yamlTestPath)
          .writeAsString('''${yamlContent}certificate_path: $pfxTestPath  
  certificate_password: 1234''');
      await config.getConfigValues();
      expect(config.certificatePath, pfxTestPath);
    });

    test('invalid certificate path', () async {
      await File(yamlTestPath).writeAsString(
          '${yamlContent}certificate_path: $tempFolderPath/test123.pfx');
      await config.getConfigValues();
      await expectLater(
          config.validateConfigValues,
          throwsA(predicate((String error) =>
              error.contains('The file certificate not found in'))));
    });

    test('certificate without password', () async {
      const pfxTestPath = '$tempFolderPath/test.pfx';
      await File(pfxTestPath).create();
      await File(yamlTestPath)
          .writeAsString('${yamlContent}certificate_path: $pfxTestPath');
      await config.getConfigValues();
      await expectLater(
          config.validateConfigValues,
          throwsA(predicate((String error) =>
              error.contains('Certificate password is empty'))));
    });
  });
}
