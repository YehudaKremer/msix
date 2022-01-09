import 'dart:io';
import 'package:image/image.dart';
import '../utils/log.dart';
import '../configuration.dart';
import '../utils/injector.dart';

void generateIcons() {
  const taskName = 'generating icons';
  Log.startingTask(taskName);
  final _config = injector.get<Configuration>();

  if (!File(_config.logoPath!).existsSync()) {
    Log.errorAndExit('Logo file not found at ${_config.logoPath}');
  }

  Image image;

  try {
    image = decodeImage(File(_config.logoPath!).readAsBytesSync())!;
  } catch (e) {
    Log.errorAndExit('Error reading logo file: ${_config.logoPath!}');
    exit(-1);
  }

  // SmallTile
  AssetIcon smallTile = AssetIcon('SmallTile', image, const Size(71, 71),
      paddingWidthPercent: 0.34, paddingHeightPercent: 0.34);
  smallTile.withScale(1.25);
  smallTile.withScale(1.5);
  smallTile.withScale(2);
  smallTile.withScale(4);

  // Square150x150Logo (Medium tile)
  AssetIcon square150x150Logo = AssetIcon(
      'Square150x150Logo', image, const Size(150, 150),
      paddingWidthPercent: 0.34, paddingHeightPercent: 0.5);
  square150x150Logo.withScale(1.25);
  square150x150Logo.withScale(1.5);
  square150x150Logo.withScale(2);
  square150x150Logo.withScale(4);

  // Wide310x150Logo (Wide tile)
  AssetIcon wide310x150 = AssetIcon(
      'Wide310x150Logo', image, const Size(310, 150),
      paddingWidthPercent: 0.34, paddingHeightPercent: 0.5);
  wide310x150.withScale(1.25);
  wide310x150.withScale(1.5);
  wide310x150.withScale(2);
  wide310x150.withScale(4);

  // LargeTile
  AssetIcon largeTile = AssetIcon('LargeTile', image, const Size(310, 310),
      paddingWidthPercent: 0.34, paddingHeightPercent: 0.5);
  largeTile.withScale(1.25);
  largeTile.withScale(1.5);
  largeTile.withScale(2);
  largeTile.withScale(4);

  // Square44x44Logo (App icon)
  AssetIcon square44x44Logo = AssetIcon(
      'Square44x44Logo', image, const Size(44, 44),
      paddingWidthPercent: 0.16, paddingHeightPercent: 0.16);
  square44x44Logo.withScale(1.25);
  square44x44Logo.withScale(1.5);
  square44x44Logo.withScale(2);
  square44x44Logo.withScale(4);

  // targetsize
  AssetIcon('Square44x44Logo.targetsize-16', image, const Size(16, 16));
  AssetIcon('Square44x44Logo.targetsize-24', image, const Size(24, 24));
  AssetIcon('Square44x44Logo.targetsize-32', image, const Size(32, 32));
  AssetIcon('Square44x44Logo.targetsize-48', image, const Size(48, 48));
  AssetIcon('Square44x44Logo.targetsize-256', image, const Size(256, 256));
  AssetIcon('Square44x44Logo.targetsize-20', image, const Size(20, 20));
  AssetIcon('Square44x44Logo.targetsize-30', image, const Size(30, 30));
  AssetIcon('Square44x44Logo.targetsize-36', image, const Size(36, 36));
  AssetIcon('Square44x44Logo.targetsize-40', image, const Size(40, 40));
  AssetIcon('Square44x44Logo.targetsize-60', image, const Size(60, 60));
  AssetIcon('Square44x44Logo.targetsize-64', image, const Size(64, 64));
  AssetIcon('Square44x44Logo.targetsize-72', image, const Size(72, 72));
  AssetIcon('Square44x44Logo.targetsize-80', image, const Size(80, 80));
  AssetIcon('Square44x44Logo.targetsize-96', image, const Size(96, 96));

  // unplated targetsize
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-16', image,
      const Size(16, 16));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-24', image,
      const Size(24, 24));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-32', image,
      const Size(32, 32));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-48', image,
      const Size(48, 48));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-256', image,
      const Size(256, 256));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-20', image,
      const Size(20, 20));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-30', image,
      const Size(30, 30));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-36', image,
      const Size(36, 36));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-40', image,
      const Size(40, 40));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-60', image,
      const Size(60, 60));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-64', image,
      const Size(64, 64));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-72', image,
      const Size(72, 72));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-80', image,
      const Size(80, 80));
  AssetIcon('Square44x44Logo.altform-unplated_targetsize-96', image,
      const Size(96, 96));

  // light unplated targetsize
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-16', image,
      const Size(16, 16));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-24', image,
      const Size(24, 24));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-32', image,
      const Size(32, 32));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-48', image,
      const Size(48, 48));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-256', image,
      const Size(256, 256));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-20', image,
      const Size(20, 20));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-30', image,
      const Size(30, 30));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-36', image,
      const Size(36, 36));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-40', image,
      const Size(40, 40));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-60', image,
      const Size(60, 60));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-64', image,
      const Size(64, 64));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-72', image,
      const Size(72, 72));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-80', image,
      const Size(80, 80));
  AssetIcon('Square44x44Logo.altform-lightunplated_targetsize-96', image,
      const Size(96, 96));

  // SplashScreen
  AssetIcon splashScreen = AssetIcon(
      'SplashScreen', image, const Size(620, 300),
      paddingWidthPercent: 0.34, paddingHeightPercent: 0.5);
  splashScreen.withScale(1.25);
  splashScreen.withScale(1.5);
  splashScreen.withScale(2);
  splashScreen.withScale(4);

  // BadgeLogo
  AssetIcon badgeLogo = AssetIcon('BadgeLogo', image, const Size(24, 24));
  badgeLogo.withScale(1.25);
  badgeLogo.withScale(1.5);
  badgeLogo.withScale(2);
  badgeLogo.withScale(4);

  // StoreLogo
  AssetIcon storeLogo = AssetIcon('StoreLogo', image, const Size(50, 50));
  storeLogo.withScale(1.25);
  storeLogo.withScale(1.5);
  storeLogo.withScale(2);
  storeLogo.withScale(4);

  Log.taskCompleted(taskName);
}

class Size {
  final int width;
  final int height;
  const Size(this.width, this.height);
}

class AssetIcon {
  String name;
  Image image;
  Size size;
  double scale;
  double paddingWidthPercent;
  double paddingHeightPercent;
  final _config = injector.get<Configuration>();

  AssetIcon(this.name, this.image, this.size,
      {this.scale = 1,
      this.paddingWidthPercent = 0,
      this.paddingHeightPercent = 0}) {
    generate();
  }

  AssetIcon withScale(double scale) {
    return AssetIcon(
      name,
      image,
      size,
      scale: scale,
      paddingWidthPercent: paddingWidthPercent,
      paddingHeightPercent: paddingHeightPercent,
    );
  }

  generate() {
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

    File('${_config.buildFilesFolder}/Images/$fileName.png')
        .writeAsBytesSync(encodePng(imageCanvas));
  }
}
