import 'dart:io';
import 'dart:isolate';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:cli_util/cli_logging.dart';
import 'configuration.dart';
import 'method_extensions.dart';

/// Handles all the msix and user assets files
class Assets {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();
  late Image image;
  String get _msixIconsFolderPath => '${_config.buildFilesFolder}/Images';

  /// Generate new app icons or copy default app icons
  Future<void> createIcons() async {
    _logger.trace('create app icons');

    await Directory(_msixIconsFolderPath).create();

    if (_config.logoPath != null) {
      _logger.trace('generating icons');

      if (!(await File(_config.logoPath!).exists())) {
        throw 'Logo file not found at ${_config.logoPath}';
      }

      try {
        image = decodeImage(await File(_config.logoPath!).readAsBytes())!;
      } catch (e) {
        throw 'Error reading logo file: ${_config.logoPath!}';
      }

      var generateAssetsIconsParts = [
        _generateAssetsIconsPart1,
        _generateAssetsIconsPart2,
        _generateAssetsIconsPart3,
      ];

      Iterable<Future> isolatesFutures = [
        ReceivePort(),
        ReceivePort(),
        ReceivePort(),
      ]
          .asMap()
          .map((index, port) => MapEntry(index, [
                Isolate.spawn(generateAssetsIconsParts[index], port.sendPort),
                port.first
              ]))
          .values
          .expand((i) => i);

      await Future.wait(isolatesFutures);
    } else {
      await _copyDefaultsIcons();
    }
  }

  Future<void> _copyDefaultsIcons() async =>
      await Directory(_config.defaultsIconsFolderPath)
          .copyDirectory(Directory(_msixIconsFolderPath));

  /// Copy the VC libs files (msvcp140.dll, vcruntime140.dll, vcruntime140_1.dll)
  Future<void> copyVCLibsFiles() async {
    _logger.trace('copying VC libraries');

    await Directory('${_config.msixAssetsPath}/VCLibs/${_config.architecture}')
        .copyDirectory(Directory(_config.buildFilesFolder));
  }

  /// Clear the build folder from temporary files
  Future<void> cleanTemporaryFiles({clearMsixFiles = false}) async {
    _logger.trace('cleaning temporary files');

    final buildPath = _config.buildFilesFolder;

    await Future.wait([
      ...[
        'AppxManifest.xml',
        'resources.pri',
        'resources.scale-125.pri',
        'resources.scale-150.pri',
        'resources.scale-200.pri',
        'resources.scale-400.pri',
        'msvcp140.dll',
        'vcruntime140_1.dll',
        'vcruntime140.dll'
      ].map((fileName) async =>
          await File('$buildPath/$fileName').deleteIfExists()),
      Directory('$buildPath/Images').deleteIfExists(recursive: true),
      clearMsixFiles
          ? Directory(buildPath)
              .list(recursive: true, followLinks: false)
              .where((f) => basename(f.path).contains('.msix'))
              .forEach((file) async => await file.deleteIfExists())
          : Future.value(),
    ]);

    if (clearMsixFiles) {
      await Future.wait([
        ...[
          'installCertificate.ps1',
          'InstallTestCertificate.exe',
          'test_certificate.pfx'
        ].map((fileName) async =>
            await File('$buildPath/$fileName').deleteIfExists()),
      ]);
    }
  }

  /// Generate icon with specified size, padding and scale
  Future<void> _generateIcon(String name, _Size size,
      {double scale = 1}) async {
    int scaledWidth = (size.width * scale).ceil();
    int scaledHeight = (size.height * scale).ceil();
    Interpolation interpolation = scaledWidth < 200 || scaledHeight < 200
        ? Interpolation.average
        : Interpolation.cubic;

    if (_config.trimLogo) {
      try {
        image = trim(image);
      } catch (_) {}
    }

    image = image.convert(numChannels: 4);

    Image resizedImage;
    if (scaledWidth > scaledHeight) {
      resizedImage = copyResize(
        image,
        height: scaledHeight,
        interpolation: interpolation,
      );
    } else {
      resizedImage = copyResize(
        image,
        width: scaledWidth,
        interpolation: interpolation,
      );
    }

    Image imageCanvas = Image(
      width: scaledWidth.ceil(),
      height: scaledHeight.ceil(),
      numChannels: 4,
    );

    compositeImage(
      imageCanvas,
      resizedImage,
      center: true,
      linearBlend: true,
    );

    String fileName = name;
    if (!name.contains('targetsize')) {
      fileName = '$name.scale-${(scale * 100).toInt()}';
    }

    await File('${_config.buildFilesFolder}/Images/$fileName.png')
        .writeAsBytes(encodePng(imageCanvas));
  }

  /// Generate optimized msix icons from the user logo
  Future<void> _generateAssetsIconsPart1(SendPort port) async {
    await Future.wait([
      // SmallTile
      _generateIcon('SmallTile', const _Size(71, 71)),
      _generateIcon('SmallTile', const _Size(71, 71), scale: 1.25),
      _generateIcon('SmallTile', const _Size(71, 71), scale: 1.5),
      _generateIcon('SmallTile', const _Size(71, 71), scale: 2),
      _generateIcon('SmallTile', const _Size(71, 71), scale: 4),
      // Square150x150Logo (Medium tile)
      _generateIcon(
        'Square150x150Logo',
        const _Size(150, 150),
      ),
      _generateIcon('Square150x150Logo', const _Size(150, 150), scale: 1.25),
      _generateIcon('Square150x150Logo', const _Size(150, 150), scale: 1.5),
      _generateIcon('Square150x150Logo', const _Size(150, 150), scale: 2),
      _generateIcon('Square150x150Logo', const _Size(150, 150), scale: 4),
      // Wide310x150Logo (Wide tile)
      _generateIcon(
        'Wide310x150Logo',
        const _Size(310, 150),
      ),
      _generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 1.25),
      _generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 1.5),
      _generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 2),
      _generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 4),
      // LargeTile
      _generateIcon(
        'LargeTile',
        const _Size(310, 310),
      ),
      _generateIcon('LargeTile', const _Size(310, 310), scale: 1.25),
      _generateIcon('LargeTile', const _Size(310, 310), scale: 1.5),
      _generateIcon('LargeTile', const _Size(310, 310), scale: 2),
      _generateIcon('LargeTile', const _Size(310, 310), scale: 4),
      // Square44x44Logo (App icon)
      _generateIcon(
        'Square44x44Logo',
        const _Size(44, 44),
      ),
      _generateIcon('Square44x44Logo', const _Size(44, 44), scale: 1.25),
      _generateIcon('Square44x44Logo', const _Size(44, 44), scale: 1.5),
      _generateIcon('Square44x44Logo', const _Size(44, 44), scale: 2),
      _generateIcon('Square44x44Logo', const _Size(44, 44), scale: 4),
    ]);

    Isolate.exit(port);
  }

  Future<void> _generateAssetsIconsPart2(SendPort port) async {
    await Future.wait([
      // targetsize
      _generateIcon('Square44x44Logo.targetsize-16', const _Size(16, 16)),
      _generateIcon('Square44x44Logo.targetsize-24', const _Size(24, 24)),
      _generateIcon('Square44x44Logo.targetsize-32', const _Size(32, 32)),
      _generateIcon('Square44x44Logo.targetsize-48', const _Size(48, 48)),
      _generateIcon('Square44x44Logo.targetsize-256', const _Size(256, 256)),
      _generateIcon('Square44x44Logo.targetsize-20', const _Size(20, 20)),
      _generateIcon('Square44x44Logo.targetsize-30', const _Size(30, 30)),
      _generateIcon('Square44x44Logo.targetsize-36', const _Size(36, 36)),
      _generateIcon('Square44x44Logo.targetsize-40', const _Size(40, 40)),
      _generateIcon('Square44x44Logo.targetsize-60', const _Size(60, 60)),
      _generateIcon('Square44x44Logo.targetsize-64', const _Size(64, 64)),
      _generateIcon('Square44x44Logo.targetsize-72', const _Size(72, 72)),
      _generateIcon('Square44x44Logo.targetsize-80', const _Size(80, 80)),
      _generateIcon('Square44x44Logo.targetsize-96', const _Size(96, 96)),
      // unplated targetsize
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-16',
          const _Size(16, 16)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-24',
          const _Size(24, 24)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-32',
          const _Size(32, 32)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-48',
          const _Size(48, 48)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-256',
          const _Size(256, 256)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-20',
          const _Size(20, 20)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-30',
          const _Size(30, 30)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-36',
          const _Size(36, 36)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-40',
          const _Size(40, 40)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-60',
          const _Size(60, 60)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-64',
          const _Size(64, 64)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-72',
          const _Size(72, 72)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-80',
          const _Size(80, 80)),
      _generateIcon('Square44x44Logo.altform-unplated_targetsize-96',
          const _Size(96, 96)),
    ]);

    Isolate.exit(port);
  }

  Future<void> _generateAssetsIconsPart3(SendPort port) async {
    await Future.wait([
      // light unplated targetsize
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-16',
          const _Size(16, 16)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-24',
          const _Size(24, 24)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-32',
          const _Size(32, 32)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-48',
          const _Size(48, 48)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-256',
          const _Size(256, 256)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-20',
          const _Size(20, 20)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-30',
          const _Size(30, 30)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-36',
          const _Size(36, 36)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-40',
          const _Size(40, 40)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-60',
          const _Size(60, 60)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-64',
          const _Size(64, 64)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-72',
          const _Size(72, 72)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-80',
          const _Size(80, 80)),
      _generateIcon('Square44x44Logo.altform-lightunplated_targetsize-96',
          const _Size(96, 96)),
      // SplashScreen
      _generateIcon(
        'SplashScreen',
        const _Size(620, 300),
      ),
      _generateIcon('SplashScreen', const _Size(620, 300), scale: 1.25),
      _generateIcon('SplashScreen', const _Size(620, 300), scale: 1.5),
      _generateIcon('SplashScreen', const _Size(620, 300), scale: 2),
      _generateIcon('SplashScreen', const _Size(620, 300), scale: 4),
      // BadgeLogo
      _generateIcon('BadgeLogo', const _Size(24, 24)),
      _generateIcon('BadgeLogo', const _Size(24, 24), scale: 1.25),
      _generateIcon('BadgeLogo', const _Size(24, 24), scale: 1.5),
      _generateIcon('BadgeLogo', const _Size(24, 24), scale: 2),
      _generateIcon('BadgeLogo', const _Size(24, 24), scale: 4),
      // StoreLogo
      _generateIcon('StoreLogo', const _Size(50, 50)),
      _generateIcon('StoreLogo', const _Size(50, 50), scale: 1.25),
      _generateIcon('StoreLogo', const _Size(50, 50), scale: 1.5),
      _generateIcon('StoreLogo', const _Size(50, 50), scale: 2),
      _generateIcon('StoreLogo', const _Size(50, 50), scale: 4),
    ]);

    Isolate.exit(port);
  }
}

class _Size {
  final int width;
  final int height;
  const _Size(this.width, this.height);
}
