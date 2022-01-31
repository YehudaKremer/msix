import 'dart:io';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'configuration.dart';
import 'extensions.dart';
import 'log.dart';

/// Handles all the msix/user assets files
class Assets {
  Configuration _config;
  List<File> _vCLibsFiles = [];
  late Image image;
  Log _log;

  Assets(this._config, this._log);

  ///  Create icons folder in the msix package
  Future<void> createIconsFolder() async {
    const taskName = 'creating app icons folder';
    _log.startingTask(taskName);

    var iconsFolderPath = '${_config.buildFilesFolder}\\Images';
    try {
      await Directory(iconsFolderPath).create();
    } catch (e) {
      _log.errorAndExit(GeneralException(
          'fail to create app icons folder in: $iconsFolderPath\n$e'));
    }

    _log.taskCompleted(taskName);
  }

  /// Copy default or generate app icons to icons folder in the msix package
  Future<void> copyIcons() async {
    const taskName = 'copying app icons';
    _log.startingTask(taskName);

    if (_config.haveLogoPath()) {
      try {
        await _generateAssetsIcons();
      } catch (e) {
        _log.errorAndExit(GeneralException('Error generating icons: $e'));
        _log.warn(
            'fail to generate icons from: "${_config.logoPath!}", using defaults icons instead.');
        _log.warn('please report this to:');
        _log.link('https://github.com/YehudaKremer/msix/issues');

        _copyGeneratedIcons(_config.defaultsIconsFolderPath());
      }
    } else {
      _copyGeneratedIcons(_config.defaultsIconsFolderPath());
    }

    _log.taskCompleted(taskName);
  }

  /// Copy the vc libs files (msvcp140.dll, vcruntime140.dll, vcruntime140_1.dll) to the msix package
  Future<void> copyVCLibsFiles() async {
    const taskName = 'copying VC libraries';
    _log.startingTask(taskName);

    _vCLibsFiles = _getAllDirectoryFiles(
        '${_config.vcLibsFolderPath()}/${_config.architecture}');

    for (File file in _vCLibsFiles) {
      await File(file.path)
          .copy('${_config.buildFilesFolder}/${basename(file.path)}');
    }

    _log.taskCompleted(taskName);
  }

  /// Clear the build folder from temporary files
  Future<void> cleanTemporaryFiles({clearMsixFiles = false}) async {
    const taskName = 'cleaning temporary files';
    _log.startingTask(taskName);

    final buildPath = _config.buildFilesFolder;

    try {
      await Future.wait([
        ...[
          'AppxManifest.xml',
          'resources.pri',
          'resources.scale-125.pri',
          'resources.scale-150.pri',
          'resources.scale-200.pri',
          'resources.scale-400.pri'
        ].map((fileName) async =>
            await File('$buildPath/$fileName').deleteIfExists()),
        Directory('$buildPath/Images').deleteIfExists(recursive: true),
        clearMsixFiles
            ? Directory(buildPath)
                .list(recursive: true, followLinks: false)
                .where((f) => basename(f.path).contains('.msix'))
                .forEach((file) async => await file.delete())
            : Future.value()
      ]);

      _vCLibsFiles.forEach((file) async =>
          await File('$buildPath/${basename(file.path)}').deleteIfExists());
    } catch (e) {
      _log.errorAndExit(GeneralException(
          'fail to clean temporary files from $buildPath: $e'));
    }

    _log.taskCompleted(taskName);
  }

  List<File> _getAllDirectoryFiles(String directory) => Directory(directory)
      .listSync(recursive: true, followLinks: false)
      .map((e) => File(e.path))
      .toList();

  /// Copy directory content (filses and sub directories)
  void _copyDirectory(Directory source, Directory destination) {
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

  /// Generate icon with specified size, padding and scale
  Future<void> _generateIcon(String name, Size size,
      {double scale = 1,
      double paddingWidthPercent = 0,
      double paddingHeightPercent = 0}) async {
    double scaledWidth = size.width * scale;
    double scaledHeight = size.height * scale;
    int widthLessPaddingWidth =
        (scaledWidth - (scaledWidth * paddingWidthPercent)).ceil();
    int heightLessPaddingHeight =
        (scaledHeight - (scaledHeight * paddingHeightPercent)).ceil();
    Interpolation interpolation =
        widthLessPaddingWidth < 200 || heightLessPaddingHeight < 200
            ? Interpolation.average
            : Interpolation.cubic;

    try {
      image = trim(image);
    } catch (e) {}

    Image resizedImage;
    if (widthLessPaddingWidth > heightLessPaddingHeight) {
      resizedImage = copyResize(
        image,
        height: heightLessPaddingHeight,
        interpolation: interpolation,
      );
    } else {
      resizedImage = copyResize(
        image,
        width: widthLessPaddingWidth,
        interpolation: interpolation,
      );
    }

    Image imageCanvas = Image(scaledWidth.ceil(), scaledHeight.ceil());

    var drawX = imageCanvas.width ~/ 2 - resizedImage.width ~/ 2;
    var drawY = imageCanvas.height ~/ 2 - resizedImage.height ~/ 2;
    drawImage(
      imageCanvas,
      resizedImage,
      dstX: drawX > 0 ? drawX : 0,
      dstY: drawY > 0 ? drawY : 0,
      blend: false,
    );

    String fileName = name;
    if (!name.contains('targetsize')) {
      fileName = '$name.scale-${(scale * 100).toInt()}';
    }

    await File('${_config.buildFilesFolder}/Images/$fileName.png')
        .writeAsBytes(encodePng(imageCanvas));
  }

  /// Generate optimized msix icons from the user logo
  Future<void> _generateAssetsIcons() async {
    const taskName = 'generating icons';
    _log.startingTask(taskName);

    if (!(await File(_config.logoPath!).exists())) {
      _log.errorAndExit(
          GeneralException('Logo file not found at ${_config.logoPath}'));
    }

    try {
      image = decodeImage(await File(_config.logoPath!).readAsBytes())!;
    } catch (e) {
      _log.errorAndExit(
          GeneralException('Error reading logo file: ${_config.logoPath!}'));
      exit(-1);
    }

    await Future.wait([
      // SmallTile
      _generateIcon('SmallTile', Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('SmallTile', Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 1.25),
      _generateIcon('SmallTile', Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 1.5),
      _generateIcon('SmallTile', Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 2),
      _generateIcon('SmallTile', Size(71, 71),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.34, scale: 4),
      // Square150x150Logo (Medium tile)
      _generateIcon('Square150x150Logo', Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('Square150x150Logo', Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('Square150x150Logo', Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('Square150x150Logo', Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('Square150x150Logo', Size(150, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // Wide310x150Logo (Wide tile)
      _generateIcon('Wide310x150Logo', Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('Wide310x150Logo', Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('Wide310x150Logo', Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('Wide310x150Logo', Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('Wide310x150Logo', Size(310, 150),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // LargeTile
      _generateIcon('LargeTile', Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('LargeTile', Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('LargeTile', Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('LargeTile', Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('LargeTile', Size(310, 310),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // Square44x44Logo (App icon)
      _generateIcon('Square44x44Logo', Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16),
      _generateIcon('Square44x44Logo', Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 1.25),
      _generateIcon('Square44x44Logo', Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 1.5),
      _generateIcon('Square44x44Logo', Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 2),
      _generateIcon('Square44x44Logo', Size(44, 44),
          paddingWidthPercent: 0.16, paddingHeightPercent: 0.16, scale: 4),
      // targetsize
      _generateIcon('Square44x44Logo.targetsize-16', Size(16, 16)),
      _generateIcon('Square44x44Logo.targetsize-24', Size(24, 24)),
      _generateIcon('Square44x44Logo.targetsize-32', Size(32, 32)),
      _generateIcon('Square44x44Logo.targetsize-48', Size(48, 48)),
      _generateIcon('Square44x44Logo.targetsize-256', Size(256, 256)),
      _generateIcon('Square44x44Logo.targetsize-20', Size(20, 20)),
      _generateIcon('Square44x44Logo.targetsize-30', Size(30, 30)),
      _generateIcon('Square44x44Logo.targetsize-36', Size(36, 36)),
      _generateIcon('Square44x44Logo.targetsize-40', Size(40, 40)),
      _generateIcon('Square44x44Logo.targetsize-60', Size(60, 60)),
      _generateIcon('Square44x44Logo.targetsize-64', Size(64, 64)),
      _generateIcon('Square44x44Logo.targetsize-72', Size(72, 72)),
      _generateIcon('Square44x44Logo.targetsize-80', Size(80, 80)),
      _generateIcon('Square44x44Logo.targetsize-96', Size(96, 96)),
      // unplated targetsize
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-16', Size(16, 16)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-24', Size(24, 24)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-32', Size(32, 32)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-48', Size(48, 48)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-256', Size(256, 256)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-20', Size(20, 20)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-30', Size(30, 30)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-36', Size(36, 36)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-40', Size(40, 40)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-60', Size(60, 60)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-64', Size(64, 64)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-72', Size(72, 72)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-80', Size(80, 80)),
      _generateIcon(
          'Square44x44Logo.altform-unplated_targetsize-96', Size(96, 96)),
      // light unplated targetsize
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-16', Size(16, 16)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-24', Size(24, 24)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-32', Size(32, 32)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-48', Size(48, 48)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-256',
          Size(256, 256)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-20', Size(20, 20)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-30', Size(30, 30)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-36', Size(36, 36)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-40', Size(40, 40)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-60', Size(60, 60)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-64', Size(64, 64)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-72', Size(72, 72)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-80', Size(80, 80)),
      _generateIcon(
          'Square44x44Logo.altform-lightunplated_targetsize-96', Size(96, 96)),
      // SplashScreen
      _generateIcon('SplashScreen', Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5),
      _generateIcon('SplashScreen', Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.25),
      _generateIcon('SplashScreen', Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 1.5),
      _generateIcon('SplashScreen', Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 2),
      _generateIcon('SplashScreen', Size(620, 300),
          paddingWidthPercent: 0.34, paddingHeightPercent: 0.5, scale: 4),
      // BadgeLogo
      _generateIcon('BadgeLogo', Size(24, 24)),
      _generateIcon('BadgeLogo', Size(24, 24), scale: 1.25),
      _generateIcon('BadgeLogo', Size(24, 24), scale: 1.5),
      _generateIcon('BadgeLogo', Size(24, 24), scale: 2),
      _generateIcon('BadgeLogo', Size(24, 24), scale: 4),
      // StoreLogo
      _generateIcon('StoreLogo', Size(50, 50)),
      _generateIcon('StoreLogo', Size(50, 50), scale: 1.25),
      _generateIcon('StoreLogo', Size(50, 50), scale: 1.5),
      _generateIcon('StoreLogo', Size(50, 50), scale: 2),
      _generateIcon('StoreLogo', Size(50, 50), scale: 4),
    ]);

    _log.taskCompleted(taskName);
  }

  /// Copy generated icons to icons folder in the msix package
  void _copyGeneratedIcons(String iconsFolderPath) async {
    for (File file in _getAllDirectoryFiles(iconsFolderPath)) {
      final path = file.path, newPath = 'Images/${basename(path)}';

      try {
        File(path).copySync('${_config.buildFilesFolder}/$newPath');
      } catch (e) {
        _log.errorAndExit(GeneralException('fail to copy icon: $path\n$e'));
      }
    }
  }
}

class Size {
  final int width;
  final int height;
  const Size(this.width, this.height);
}
