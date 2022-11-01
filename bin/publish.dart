import 'package:msix/main.dart' as msix;

// TODO: delete this file after beta
@Deprecated("use \"msix publish\" command")
Future<void> main(List<String> arguments) async {
  msix.main(['publish', ...arguments]);
}
