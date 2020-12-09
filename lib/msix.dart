import 'dart:io';
import 'package:path/path.dart';
import 'src/utils.dart';
import 'src/configuration.dart';
import 'src/constants.dart';
import 'src/msixFiles.dart';

class Msix {
  Configuration _configuration;
  MsixFiles _msixFiles;

  Msix() {
    _configuration = Configuration();
    _msixFiles = MsixFiles(_configuration);
  }

  /// Create and sign msix installer file
  Future<void> createMsix(List<String> args) async {
    await _configuration.getConfigValues(args);
    await _configuration.validateConfigValues();
    await _msixFiles.createIconsFolder();
    await _msixFiles.copyIcons();
    await _msixFiles.generateAppxManifest();
    await _msixFiles.copyVCLibsFiles();

    stdout.write(white('packing..  '));
    var packResults = await _pack();

    if (packResults.stderr.toString().length > 0) {
      print(red(packResults.stdout));
      print(red(packResults.stderr));
      exit(0);
    } else if (packResults.exitCode != 0) {
      print(red(packResults.stdout));
      exit(0);
    }
    print(green('[√]'));

    if (isNullOrStringNull(_configuration.certificatePath)) {
      print(yellow(
          'skip signing step reason: Publisher provided but not Certificate Path'));
    } else {
      stdout.write(white('singing..  '));
      var signResults = await _sign();

      if (!signResults.stdout
              .toString()
              .contains('Number of files successfully Signed: 1') &&
          signResults.stderr.toString().length > 0) {
        print(red(signResults.stdout));
        print(red(signResults.stderr));

        if (signResults.stdout
                .toString()
                .contains('Error: SignerSign() failed.') &&
            !isNullOrStringNull(_configuration.publisher)) {
          printCertificateSubjectHelp();
        }

        exit(0);
      } else if (packResults.exitCode != 0) {
        print(red(signResults.stdout));
        exit(0);
      }

      if (_configuration.isUsingTestCertificate) {
        stdout.write(green('[√]'));
        print(yellow(' *no certificate was specified, using TEST certificate'));
      } else
        print(green('[√]'));
    }

    await _msixFiles.cleanTemporaryFiles();

    print('');
    print(green('Msix installer created in:'));
    print(blue('${_configuration.buildFilesFolder}'.replaceAll('/', r'\')));

    if (_configuration.isUsingTestCertificate) printTestCertificateHelp();
  }

  Future<ProcessResult> _pack() async {
    var msixPath =
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix';
    var makeappxPath =
        '${_configuration.msixToolkitPath()}/Redist.${_configuration.architecture}/makeappx.exe';

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
        '${_configuration.msixToolkitPath()}/Redist.${_configuration.architecture}/signtool.exe';

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
