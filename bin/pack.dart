import 'package:msix/main.dart' as msix;

// TODO: delete this file after beta
@Deprecated("use \"pack publish\" command")
Future<void> main(List<String> arguments) async {
  msix.main(['pack', ...arguments]);
}
