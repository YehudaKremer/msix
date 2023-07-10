import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:isolate';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:cli_util/cli_logging.dart';
import 'configuration.dart';
import 'method_extensions.dart';
import 'dart:async';

/// Handles all the msix and user assets files
class Assets {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();
  String get _msixIconsFolderPath => p.join(_config.buildFilesFolder, 'Images');

  /// Generate new app icons or copy default app icons
  Future<void> createIcons() async {
    _logger.trace('create app icons');
    String? logoPath = _config.logoPath;

    await Directory(_msixIconsFolderPath).create();

    if (logoPath != null) {
      _logger.trace('generating icons');

      if (!(await File(logoPath).exists())) {
        throw 'Logo file not found at $logoPath';
      }

      bool trimLogo = _config.trimLogo;
      String buildFilesFolder = _config.buildFilesFolder;
      Image image;

      try {
        image = decodeImage(await File(logoPath).readAsBytes())!;
      } catch (e) {
        throw 'Error reading logo file: $logoPath';
      }

      /// Generate icon with specified size, padding and scale
      Future<void> generateIcon(String name, _Size size,
          {double scale = 1}) async {
        int scaledWidth = (size.width * scale).ceil();
        int scaledHeight = (size.height * scale).ceil();
        Interpolation interpolation = scaledWidth < 200 || scaledHeight < 200
            ? Interpolation.average
            : Interpolation.cubic;

        if (trimLogo) {
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

        await File(p.join(buildFilesFolder, 'Images', '$fileName.png'))
            .writeAsBytes(encodePng(imageCanvas));
      }

      /// Generate optimized msix icons from the user logo
      await Future.wait([
        Isolate.run(() async {
          await Future.wait([
            // SmallTile
            generateIcon('SmallTile', const _Size(71, 71)),
            generateIcon('SmallTile', const _Size(71, 71), scale: 1.25),
            generateIcon('SmallTile', const _Size(71, 71), scale: 1.5),
            generateIcon('SmallTile', const _Size(71, 71), scale: 2),
            generateIcon('SmallTile', const _Size(71, 71), scale: 4),
            // Square150x150Logo (Medium tile)
            generateIcon(
              'Square150x150Logo',
              const _Size(150, 150),
            ),
            generateIcon('Square150x150Logo', const _Size(150, 150),
                scale: 1.25),
            generateIcon('Square150x150Logo', const _Size(150, 150),
                scale: 1.5),
            generateIcon('Square150x150Logo', const _Size(150, 150), scale: 2),
            generateIcon('Square150x150Logo', const _Size(150, 150), scale: 4),
            // Wide310x150Logo (Wide tile)
            generateIcon(
              'Wide310x150Logo',
              const _Size(310, 150),
            ),
            generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 1.25),
            generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 1.5),
            generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 2),
            generateIcon('Wide310x150Logo', const _Size(310, 150), scale: 4),
            // LargeTile
            generateIcon(
              'LargeTile',
              const _Size(310, 310),
            ),
            generateIcon('LargeTile', const _Size(310, 310), scale: 1.25),
            generateIcon('LargeTile', const _Size(310, 310), scale: 1.5),
            generateIcon('LargeTile', const _Size(310, 310), scale: 2),
            generateIcon('LargeTile', const _Size(310, 310), scale: 4),
          ]);
        }),
        Isolate.run(() async {
          await Future.wait([
            // Square44x44Logo (App icon)
            generateIcon(
              'Square44x44Logo',
              const _Size(44, 44),
            ),
            generateIcon('Square44x44Logo', const _Size(44, 44), scale: 1.25),
            generateIcon('Square44x44Logo', const _Size(44, 44), scale: 1.5),
            generateIcon('Square44x44Logo', const _Size(44, 44), scale: 2),
            generateIcon('Square44x44Logo', const _Size(44, 44), scale: 4),
            // targetsize
            generateIcon('Square44x44Logo.targetsize-16', const _Size(16, 16)),
            generateIcon('Square44x44Logo.targetsize-24', const _Size(24, 24)),
            generateIcon('Square44x44Logo.targetsize-32', const _Size(32, 32)),
            generateIcon('Square44x44Logo.targetsize-48', const _Size(48, 48)),
            generateIcon(
                'Square44x44Logo.targetsize-256', const _Size(256, 256)),
            generateIcon('Square44x44Logo.targetsize-20', const _Size(20, 20)),
            generateIcon('Square44x44Logo.targetsize-30', const _Size(30, 30)),
            generateIcon('Square44x44Logo.targetsize-36', const _Size(36, 36)),
            generateIcon('Square44x44Logo.targetsize-40', const _Size(40, 40)),
            generateIcon('Square44x44Logo.targetsize-60', const _Size(60, 60)),
            generateIcon('Square44x44Logo.targetsize-64', const _Size(64, 64)),
            generateIcon('Square44x44Logo.targetsize-72', const _Size(72, 72)),
            generateIcon('Square44x44Logo.targetsize-80', const _Size(80, 80)),
            generateIcon('Square44x44Logo.targetsize-96', const _Size(96, 96)),
          ]);
        }),
        Isolate.run(() async {
          await Future.wait([
            // unplated targetsize
            generateIcon('Square44x44Logo.altform-unplated_targetsize-16',
                const _Size(16, 16)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-24',
                const _Size(24, 24)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-32',
                const _Size(32, 32)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-48',
                const _Size(48, 48)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-256',
                const _Size(256, 256)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-20',
                const _Size(20, 20)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-30',
                const _Size(30, 30)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-36',
                const _Size(36, 36)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-40',
                const _Size(40, 40)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-60',
                const _Size(60, 60)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-64',
                const _Size(64, 64)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-72',
                const _Size(72, 72)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-80',
                const _Size(80, 80)),
            generateIcon('Square44x44Logo.altform-unplated_targetsize-96',
                const _Size(96, 96)),
            // light unplated targetsize
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-16',
                const _Size(16, 16)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-24',
                const _Size(24, 24)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-32',
                const _Size(32, 32)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-48',
                const _Size(48, 48)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-256',
                const _Size(256, 256)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-20',
                const _Size(20, 20)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-30',
                const _Size(30, 30)),
          ]);
        }),
        Isolate.run(() async {
          await Future.wait([
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-36',
                const _Size(36, 36)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-40',
                const _Size(40, 40)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-60',
                const _Size(60, 60)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-64',
                const _Size(64, 64)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-72',
                const _Size(72, 72)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-80',
                const _Size(80, 80)),
            generateIcon('Square44x44Logo.altform-lightunplated_targetsize-96',
                const _Size(96, 96)),
            // SplashScreen
            generateIcon(
              'SplashScreen',
              const _Size(620, 300),
            ),
            generateIcon('SplashScreen', const _Size(620, 300), scale: 1.25),
            generateIcon('SplashScreen', const _Size(620, 300), scale: 1.5),
            generateIcon('SplashScreen', const _Size(620, 300), scale: 2),
            generateIcon('SplashScreen', const _Size(620, 300), scale: 4),
            // BadgeLogo
            generateIcon('BadgeLogo', const _Size(24, 24)),
            generateIcon('BadgeLogo', const _Size(24, 24), scale: 1.25),
            generateIcon('BadgeLogo', const _Size(24, 24), scale: 1.5),
            generateIcon('BadgeLogo', const _Size(24, 24), scale: 2),
            generateIcon('BadgeLogo', const _Size(24, 24), scale: 4),
            // StoreLogo
            generateIcon('StoreLogo', const _Size(50, 50)),
            generateIcon('StoreLogo', const _Size(50, 50), scale: 1.25),
            generateIcon('StoreLogo', const _Size(50, 50), scale: 1.5),
            generateIcon('StoreLogo', const _Size(50, 50), scale: 2),
            generateIcon('StoreLogo', const _Size(50, 50), scale: 4),
          ]);
        })
      ]);
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

    await Directory(
            p.join(_config.msixAssetsPath, 'VCLibs', _config.architecture))
        .copyDirectory(Directory(_config.buildFilesFolder));
  }

  Future<void> copyContextMenuDll(String dllPath) async {
    _logger.trace('copying context menu dll');

    await File(dllPath)
        .copy(p.join(_config.buildFilesFolder, p.basename(dllPath)));
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
        'vcruntime140.dll',
        ..._config.contextMenuConfiguration?.comSurrogateServers
                .map((server) => basename(server.dllPath))
                .toList() ??
            []
      ].map((fileName) async =>
          await File(p.join(buildPath, fileName)).deleteIfExists()),
      Directory(p.join(buildPath, 'Images')).deleteIfExists(recursive: true),
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
            await File(p.join(buildPath, fileName)).deleteIfExists()),
      ]);
    }
  }
}

class _Size {
  final int width;
  final int height;
  const _Size(this.width, this.height);
}
