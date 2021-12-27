import 'dart:io';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class IconsGenerator {
  static void generateIcons() {
    const taskName = 'generating icons';
    Log.startingTask(taskName);
    final _config = injector.get<Configuration>();
    var iconsGeneratorPath =
        '${_config.iconsGeneratorPath()}/IconsGenerator.exe';

    var result = Process.runSync(iconsGeneratorPath,
        [_config.logoPath!, '${_config.buildFilesFolder}/Images']);

    if (result.stderr.toString().length > 0) {
      throw Exception(result.stderr);
    } else if (result.exitCode != 0) {
      throw Exception(result.stdout);
    }
    if (Directory('${_config.buildFilesFolder}/Images').listSync().isEmpty) {
      stdout.writeln();
      stdout.writeln();
      Log.warn(
          'fail to generate icons from: "${_config.logoPath!}", using defaults icons instead.');
      Log.warn('please report this to:');
      Log.link('https://github.com/YehudaKremer/msix/issues');
      stdout.writeln();
      throw Exception('fail to generate icons');
    }
    Log.taskCompleted(taskName);
  }
}
