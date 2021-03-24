import 'dart:io';
import 'constants.dart';

extension StringValidations on String? {
  bool get isNull => this == null || this == 'null';
}

Iterable<File> allDirectoryFiles(String directory) => Directory(directory)
    .listSync(recursive: true, followLinks: false)
    .map((e) => File(e.path));

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

extension ArgResultsReader on ArgResults {
  String? read(String key, {String? fallback}) =>
      this[key] != null && this[key].toString().length > 0
          ? this[key]
          : fallback;
}
