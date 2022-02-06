import 'package:msix/msix.dart';

Future<void> main(List<String> arguments) async {
  var msix = Msix(arguments);
  await msix.loadConfigurations();
  await msix.createMsix();
}
