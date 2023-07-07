import 'dart:io';
import 'package:msix/src/context_menu_configuration.dart';
import 'package:path/path.dart' as p;
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/configuration.dart';
import 'package:test/test.dart';

var tempFolderPath = p.join('test', 'runner', 'configuration_temp');
var yamlTestPath = p.join(tempFolderPath, 'test.yaml');

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

    await Directory(tempFolderPath).create(recursive: true);
  });

  tearDown(() async {
    GetIt.I.reset();

    if (await Directory(tempFolderPath).exists()) {
      await Directory(tempFolderPath).delete(recursive: true);
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
        'version: 1.1.3',
      );
      await config.getConfigValues();
      expect(config.msixVersion, equals('1.1.3.0'));
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
      var pfxTestPath = p.join(tempFolderPath, 'test.pfx');
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
      var pfxTestPath = p.join(tempFolderPath, 'test.pfx');
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

  group('context menu:', () {
    late File fakeContextMenuDll;
    late File fakeContextMenuDll2;
    const String testGuid = 'ba40803c-736a-41f0-ba7c-cdb3eaed7496';
    const String testGuid2 = 'ba40803c-736a-41f0-ba7c-cdb3eaed7497';

    setUp(() async {
      fakeContextMenuDll = await File(p.join(tempFolderPath, 'test.dll'))
          .create(recursive: true);

      fakeContextMenuDll2 = await File(p.join(tempFolderPath, 'test2.dll'))
          .create(recursive: true);
    });

    tearDown(() async {
      if (await fakeContextMenuDll.exists()) {
        await fakeContextMenuDll.delete();
      }

      if (await fakeContextMenuDll2.exists()) {
        await fakeContextMenuDll2.delete();
      }
    });

    test('valid context menu', () async {
      await File(yamlTestPath).writeAsString('''${yamlContent}context_menu:
    dll_path: ${fakeContextMenuDll.path}
    items:
      - type: "*"
        commands:
          - id: command1
            clsid: $testGuid
      - type: .png
        commands:
          - id: command1
            clsid: $testGuid2
            custom_dll: ${fakeContextMenuDll2.path}''');
      await config.getConfigValues();
      await config.validateConfigValues();

      expect(
          config.contextMenuConfiguration?.items.map((e) => e.toString()),
          containsAll([
            ContextMenuItem(type: '*', commands: [
              ContextMenuItemCommand(id: 'command1', clsid: testGuid)
            ]).toString(),
            ContextMenuItem(type: '.png', commands: [
              ContextMenuItemCommand(
                  id: 'command1',
                  clsid: testGuid2,
                  customDllPath: fakeContextMenuDll2.path),
            ]).toString()
          ]));

      expect(
          config.contextMenuConfiguration?.comSurrogateServers
              .map((e) => e.toString()),
          containsAll([
            ContextMenuComSurrogateServer(
              clsid: testGuid,
              dllPath: fakeContextMenuDll.path,
            ).toString(),
            ContextMenuComSurrogateServer(
              clsid: testGuid2,
              dllPath: fakeContextMenuDll2.path,
            ).toString()
          ]));
    });
  });
}
