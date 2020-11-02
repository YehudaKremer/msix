import 'dart:io';
import 'package:msix/utils.dart';
import 'package:path/path.dart';
import 'configuration.dart';
import 'constants.dart';
import 'msixFiles.dart';

class Msix {
  Configuration _configuration;
  MsixFiles _msixFiles;

  Msix() {
    _configuration = Configuration();
    _msixFiles = MsixFiles(_configuration);
  }

  Future<void> createMsix(List<String> args) async {
    await _configuration.getConfigValues();
    await _configuration.validateConfigValues();
    await _msixFiles.createIconsFolder();
    await _msixFiles.createIcons();
    await _msixFiles.generateAppxManifest();
    await _msixFiles.copyVCLibsFiles();

    print(white('packing....    '));
    var packResults = await _pack();

    if (packResults.stderr.toString().length > 0) {
      print(red(packResults.stdout));
      print(red(packResults.stderr));
      exit(0);
    } else if (packResults.exitCode != 0) {
      print(red(packResults.stdout));
      exit(0);
    }
    print(green('done!'));

    print(white('singing....    '));
    var signResults = await _sign();

    if (!signResults.stdout.toString().contains('Number of files successfully Signed: 1') &&
        signResults.stderr.toString().length > 0) {
      print(red(signResults.stdout));
      print(red(signResults.stderr));

      if (signResults.stdout.toString().contains('Error: SignerSign() failed.') &&
          !isNullOrStringNull(_configuration.certificateSubject)) {
        printCertificateSubjectHelp();
      }

      exit(0);
    } else if (packResults.exitCode != 0) {
      print(red(signResults.stdout));
      exit(0);
    }
    print(green('done!'));

    await _msixFiles.cleanTemporaryFiles();

    print('');
    print(green('The msix installer was created in the following location:'));
    print('${Directory.current.path}/${_configuration.buildFilesFolder}'.replaceAll('/', r'\'));

    if (_configuration.isUseingTestCertificate) {
      print('');
      print(yellow(
          'This maix installer is signed with TEST certificate,\nif you have not yet installed this test certificate please read the following guide:'));
      print('https://www.advancedinstaller.com/install-test-certificate-from-msix.html');
      print('');
    }
  }

  Future<ProcessResult> _pack() async {
    var msixPath = '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix';
    var makeappxPath =
        '$msixToolkitPath/Redist.${_configuration.architecture == 'x86' ? 'x86' : 'x64'}/makeappx.exe';

    if (await File(msixPath).exists()) await File(msixPath).delete();

    return await Process.run(makeappxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      _configuration.buildFilesFolder,
      '/p',
      msixPath,
    ]);
  }

  Future<ProcessResult> _sign() async {
    var signtoolPath =
        '$msixToolkitPath/Redist.${_configuration.architecture == 'x86' ? 'x86' : 'x64'}/signtool.exe';

    if (extension(_configuration.certificatePath) == '.pfx') {
      return await Process.run(signtoolPath, [
        'sign',
        '/fd',
        'SHA256',
        '/a',
        '/f',
        _configuration.certificatePath,
        '/p',
        _configuration.certificatePassword,
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix',
      ]);
    } else {
      return await Process.run(signtoolPath, [
        'sign',
        '/fd',
        'SHA256',
        '/a',
        _configuration.certificatePath,
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix',
      ]);
    }
  }
}
