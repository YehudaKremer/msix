import 'dart:io';
import 'constants.dart';

bool isNullOrStringNull(String? value) => value == null || value == 'null';

List<File> allDirectoryFiles(String directory) {
  List<File> frameworkFilePaths = [];

  var files =
      Directory(directory).listSync(recursive: true, followLinks: false);

  for (var file in files) {
    var currnetFile = File(file.path);
    if (currnetFile.existsSync()) frameworkFilePaths.add(currnetFile);
  }

  return frameworkFilePaths;
}

printCertificateSubjectHelp() {
  print(yellow(
      'Please note: The value of Publisher should be in one line and with commas, example:'));
  print(white(defaultPublisher));
  print('');
  print(yellow('For more information see:'));
  print(blue(
      'https://docs.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#determine-the-subject-of-your-packaged-app'));
  print('');
}

printTestCertificateHelp() {
  print('');
  print(yellow(
      'NOTE: This msix installer is signed with TEST certificate,\nif you have not yet installed this test certificate on your PC please read the following guide:'));
  print(blue(
      'https://www.advancedinstaller.com/install-test-certificate-from-msix.html'));
  print('');
}
