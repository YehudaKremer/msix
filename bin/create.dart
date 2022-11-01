import 'package:msix/main.dart' as msix;

// TODO: delete this file after beta
@Deprecated("use \"create publish\" command")
Future<void> main(List<String> arguments) async {
  msix.main(['create', ...arguments]);
}
