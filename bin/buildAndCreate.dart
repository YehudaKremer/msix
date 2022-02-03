import 'package:msix/msix.dart';

void main(List<String> arguments) async {
  var msix = Msix();
  await msix.loadConfigurations(arguments);
  await msix.buildWindowsFilesAndCreateMsix();
}
