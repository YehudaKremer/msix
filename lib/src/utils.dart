import 'dart:async';
import 'dart:io';
import 'constants.dart';

bool isNullOrStringNull(String value) => value == null || value == 'null';

Future<List<File>> allDirectoryFiles(String directory) async {
  List<File> frameworkFilePaths = [];

  await Directory(directory)
      .list(recursive: true, followLinks: false)
      .listen((FileSystemEntity entity) async {
    var file = File(entity.path);

    if (await file.exists()) frameworkFilePaths.add(file);
  }).asFuture();

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
