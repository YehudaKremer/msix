import 'dart:io';
import 'package:path/path.dart';
import 'cli/iconsGenerator.dart';
import 'utils/injector.dart';
import 'utils/log.dart';
import 'configuration.dart';

class Assets {
  Configuration _config;
  Iterable<File> _vCLibsFiles = [];

  Assets() : _config = injector.get<Configuration>() {
    _vCLibsFiles = _allDirectoryFiles(
        '${_config.vcLibsFolderPath()}/${_config.architecture}');
  }

  void copyAssetsFolder() {
    const taskName = 'copying assets folder';
    Log.startingTask(taskName);

    if (_config.haveAssetsFolder()) {
      var assetsFolderName = basename(_config.assetsFolderPath!);
      Directory('${_config.buildFilesFolder}/$assetsFolderName').createSync();

      _copyDirectory(Directory(_config.assetsFolderPath!),
          Directory('${_config.buildFilesFolder}/$assetsFolderName'));
    }

    Log.taskCompleted(taskName);
  }

  void createIconsFolder() {
    const taskName = 'creating app icons folder';
    Log.startingTask(taskName);

    var iconsFolderPath = '${_config.buildFilesFolder}\\Images';
    try {
      Directory(iconsFolderPath).createSync();
    } catch (e) {
      Log.errorAndExit(
          'fail to create app icons folder in: $iconsFolderPath\n$e');
    }

    Log.taskCompleted(taskName);
  }

  void copyIcons() {
    const taskName = 'copying app icons';
    Log.startingTask(taskName);

    if (_config.haveLogoPath()) {
      try {
        IconsGenerator.generateIcons();
      } catch (e) {
        _copyVsGeneratedIcons(_config.defaultsIconsFolderPath());
      }
    } else {
      _copyVsGeneratedIcons(_config.defaultsIconsFolderPath());
    }

    Log.taskCompleted(taskName);
  }

  void copyVCLibsFiles() {
    const taskName = 'copying VC libraries';
    Log.startingTask(taskName);

    for (var file in _vCLibsFiles) {
      File(file.path)
          .copySync('${_config.buildFilesFolder}/${basename(file.path)}');
    }

    Log.taskCompleted(taskName);
  }

  void cleanTemporaryFiles({clearMsixFiles = false}) {
    const taskName = 'cleaning temporary files';
    Log.startingTask(taskName);

    try {
      var appxManifest = File('${_config.buildFilesFolder}/AppxManifest.xml');
      if (appxManifest.existsSync()) appxManifest.deleteSync();

      var iconsFolder = Directory('${_config.buildFilesFolder}/Images');
      if (iconsFolder.existsSync()) iconsFolder.deleteSync(recursive: true);

      var priFile = File('${_config.buildFilesFolder}/resources.pri');
      if (priFile.existsSync()) priFile.deleteSync();

      var priFile125 =
          File('${_config.buildFilesFolder}/resources.scale-125.pri');
      if (priFile125.existsSync()) priFile125.deleteSync();

      var priFile150 =
          File('${_config.buildFilesFolder}/resources.scale-150.pri');
      if (priFile150.existsSync()) priFile150.deleteSync();

      var priFile200 =
          File('${_config.buildFilesFolder}/resources.scale-200.pri');
      if (priFile200.existsSync()) priFile200.deleteSync();

      var priFile400 =
          File('${_config.buildFilesFolder}/resources.scale-400.pri');
      if (priFile400.existsSync()) priFile400.deleteSync();

      for (var file in _vCLibsFiles) {
        var fileToDelete =
            File('${_config.buildFilesFolder}/${basename(file.path)}');
        if (fileToDelete.existsSync()) fileToDelete.deleteSync();
      }

      if (_config.haveAssetsFolder()) {
        var assetsFolderPath = Directory(
            '${_config.buildFilesFolder}/${basename(_config.assetsFolderPath!)}');
        if (assetsFolderPath.existsSync())
          assetsFolderPath.deleteSync(recursive: true);
      }

      if (clearMsixFiles) {
        Directory(_config.buildFilesFolder)
            .listSync(recursive: true, followLinks: false)
            .map((e) => File(e.path))
            .where((f) => basename(f.path).contains('.msix'))
            .forEach((file) {
          file.deleteSync();
        });
      }
    } catch (e) {
      Log.errorAndExit(
          'fail to clean temporary files from ${_config.buildFilesFolder}: $e');
    }

    Log.taskCompleted(taskName);
  }

  void _copyVsGeneratedIcons(String iconsFolderPath) {
    for (var file in _allDirectoryFiles(iconsFolderPath)) {
      _copyIconToBuildFolder(file.path);
    }
  }

  Iterable<File> _allDirectoryFiles(String directory) {
    return Directory(directory)
        .listSync(recursive: true, followLinks: false)
        .map((e) => File(e.path));
  }

  String _copyIconToBuildFolder(String iconPath) {
    final newPath = 'Images/${basename(iconPath)}';

    try {
      File(iconPath).copySync('${_config.buildFilesFolder}/$newPath');
    } catch (e) {
      Log.errorAndExit('fail to copy icon: $iconPath\n$e');
    }

    return newPath;
  }

  void _copyDirectory(Directory source, Directory destination) =>
      source.listSync(recursive: false).forEach((var entity) {
        if (entity is Directory) {
          var newDirectory =
              Directory(join(destination.absolute.path, basename(entity.path)));
          newDirectory.createSync();

          _copyDirectory(entity.absolute, newDirectory);
        } else if (entity is File) {
          entity.copySync(join(destination.path, basename(entity.path)));
        }
      });
}
