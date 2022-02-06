import 'package:msix/msix.dart';

void main(List<String> arguments) async {
  var msix = Msix(arguments);
  await msix.loadConfigurations();
  await msix.buildWindowsFilesAndCreateMsix();
}
