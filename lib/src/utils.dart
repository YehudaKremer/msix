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
      'Please note: The value of certificate_subject should be in one line and with commas, example:'));
  print(white(defaultCertificateSubject));
  print('');
  print(yellow('For more information see:'));
  print(
      'https://docs.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#determine-the-subject-of-your-packaged-app');
  print('');
}

printTestCertificateHelp() {
  print('');
  print(yellow(
      'This msix installer is signed with TEST certificate,\nif you have not yet installed this test certificate please read the following guide:'));
  print(
      'https://www.advancedinstaller.com/install-test-certificate-from-msix.html');
  print('');
}
