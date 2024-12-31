import 'package:msix/msix.dart';
import 'package:test/test.dart';

void main() => test(
  'Asset URIs are valid',
  () => expect(
    Msix.assetUri('assets/image.jpg'),
    Uri.parse('ms-appx:///data/flutter_assets/assets/image.jpg'),
  ),
);
