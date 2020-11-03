import 'dart:async';
import 'dart:io';
import 'constants.dart';

bool isNullOrStringNull(String value) => value == null || value == 'null';

Future<List<File>> allDirectoryFiles(String directory) async {
  List<File> frameworkFilePaths = [];

  await Directory(directory)
      .list(recursive: true, followLinks: false)
      .listen((FileSystemEntity entity) {
    var file = File(entity.path);
    file.exists().then((exists) {
      if (exists) frameworkFilePaths.add(file);
    });
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
