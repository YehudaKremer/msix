import 'dart:io';
import 'package:path/path.dart';
import 'injector.dart';
import 'log.dart';
import 'extensions.dart';
import 'configuration.dart';

class Assets {
  Configuration _config;
  Iterable<File> _vCLibsFiles = [];

  Assets() : _config = injector.get<Configuration>();

  void createIconsFolder() {
    Log.startTask('creating icons folder');

    var iconsFolderPath = '${_config.buildFilesFolder}\\icons';
    try {
      Directory(iconsFolderPath).createSync();
    } catch (e) {
      Log.error('fail to create icons folder in $iconsFolderPath: $e');
      exit(0);
    }

    Log.completeTask();
  }

  void copyIcons() {
    Log.startTask('copying icons');

    if (_config.vsGeneratedImagesFolderPath.isNull) {
      /// Use the logo for all icons if they null
      if (!_config.logoPath.isNull) {
        if (_config.startMenuIconPath.isNull) _config.startMenuIconPath = _config.logoPath;

        if (_config.tileIconPath.isNull) _config.tileIconPath = _config.logoPath;
      }

      _config.logoPath =
          _copyIcon(_config.logoPath, File('${_config.defaultsIconsFolderPath()}/icon.png').path);

      _config.startMenuIconPath = _copyIcon(
          _config.startMenuIconPath, File('${_config.defaultsIconsFolderPath()}/44_44.png').path);

      _config.tileIconPath = _copyIcon(
          _config.tileIconPath, File('${_config.defaultsIconsFolderPath()}/150_150.png').path);
    } else {
      final vsImages = _allDirectoryFiles(_config.vsGeneratedImagesFolderPath!);

      Directory('${_config.buildFilesFolder}/Images').createSync(recursive: true);

      for (var file in vsImages) {
        File(file.path).copySync('${_config.buildFilesFolder}/Images/${basename(file.path)}');
      }
    }

    Log.completeTask();
  }

  void copyVCLibsFiles() {
    Log.startTask('copying VC libraries');

    _vCLibsFiles = _allDirectoryFiles('${_config.vcLibsFolderPath()}/${_config.architecture}');

    for (var file in _vCLibsFiles) {
      File(file.path).copySync('${_config.buildFilesFolder}/${basename(file.path)}');
    }

    Log.completeTask();
  }

  void cleanTemporaryFiles() {
    Log.startTask('cleaning temporary files');

    try {
      var appxManifest = File('${_config.buildFilesFolder}/AppxManifest.xml');
      if (appxManifest.existsSync()) appxManifest.deleteSync();

      var iconsFolder = Directory('${_config.buildFilesFolder}/icons');
      if (iconsFolder.existsSync()) iconsFolder.deleteSync(recursive: true);

      var vsImagesFolder = Directory('${_config.buildFilesFolder}/Images');
      if (vsImagesFolder.existsSync()) vsImagesFolder.deleteSync(recursive: true);

      var priFile = File('${_config.buildFilesFolder}/resources.pri');
      if (priFile.existsSync()) priFile.deleteSync();

      var priFile125 = File('${_config.buildFilesFolder}/resources.scale-125.pri');
      if (priFile125.existsSync()) priFile125.deleteSync();

      var priFile150 = File('${_config.buildFilesFolder}/resources.scale-150.pri');
      if (priFile150.existsSync()) priFile150.deleteSync();

      var priFile200 = File('${_config.buildFilesFolder}/resources.scale-200.pri');
      if (priFile200.existsSync()) priFile200.deleteSync();

      var priFile400 = File('${_config.buildFilesFolder}/resources.scale-400.pri');
      if (priFile400.existsSync()) priFile400.deleteSync();

      for (var file in _vCLibsFiles) {
        var fileToDelete = File('${_config.buildFilesFolder}/${basename(file.path)}');
        if (fileToDelete.existsSync()) fileToDelete.deleteSync();
      }
    } catch (e) {
      Log.error('fail to clean temporary files from ${_config.buildFilesFolder}: $e');
    }

    Log.completeTask();
  }

  Iterable<File> _allDirectoryFiles(String directory) =>
      Directory(directory).listSync(recursive: true, followLinks: false).map((e) => File(e.path));

  String _copyIcon(String? iconPath, String alternativeIconPath) {
    iconPath = iconPath.isNull ? alternativeIconPath : iconPath;
    var newPath = 'icons/${basename(iconPath!)}';

    try {
      File(iconPath).copySync('${_config.buildFilesFolder}/$newPath');
    } catch (e) {
      Log.error('fail to create icon $iconPath: $e');
    }

    return newPath;
  }
}
