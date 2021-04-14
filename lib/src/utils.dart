import 'dart:io';
import 'package:args/args.dart';
import 'constants.dart';

extension StringValidations on String? {
  bool get isNull => this == null;
}

extension ArgResultsReader on ArgResults {
  String? read(String key, {String? fallback}) =>
      this[key] != null && this[key].toString().length > 0
          ? this[key]
          : fallback;
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

printTestCertificateHelp(String pfxTestPath) {
  print('');
  print(yellow('Certificate Note:'));
  print(yellow(
      'every msix installer must be signed with certificate before it can be installed.'));
  print(yellow(
      'for testing purposes we signed your msix installer with a TEST certificate,'));
  print(yellow(
      'to use this certificate you need to install it, open the certificate file:'));
  print(blue(pfxTestPath));
  print(yellow('and follow the instructions at the following link:'));
  print(blue(
      'https://www.advancedinstaller.com/install-test-certificate-from-msix.html'));
  print('');
}
