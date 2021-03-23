import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart';
import 'src/utils.dart';
import 'src/configuration.dart';
import 'src/constants.dart';
import 'src/msixFiles.dart';

class Msix {
  late Configuration _configuration;
  late MsixFiles _msixFiles;

  Msix() {
    ansiColorDisabled = false;
    _configuration = Configuration();
    _msixFiles = MsixFiles(_configuration);
  }

  /// Create and sign msix installer file
  Future<void> createMsix(List<String> args) async {
    await _configuration.getConfigValues(args);
    _configuration.validateConfigValues();
    _msixFiles.cleanTemporaryFiles();
    _msixFiles.createIconsFolder();
    _msixFiles.copyIcons();
    _msixFiles.generateAppxManifest();
    _msixFiles.copyVCLibsFiles();

    if (!_configuration.vsGeneratedImagesFolderPath.isNull) {
      stdout.write(white('generate PRI file..  '));
      var priResults = _generatePRI();

      if (priResults.stderr.toString().length > 0) {
        print(red(priResults.stdout));
        print(red(priResults.stderr));
        exit(0);
      } else if (priResults.exitCode != 0) {
        print(red(priResults.stdout));
        exit(0);
      }
      print(green('[√]'));
    }

    stdout.write(white('packing..  '));
    var packResults = _pack();

    if (packResults.stderr.toString().length > 0) {
      print(red(packResults.stdout));
      print(red(packResults.stderr));
      exit(0);
    } else if (packResults.exitCode != 0) {
      print(red(packResults.stdout));
      exit(0);
    }
    print(green('[√]'));

    if (_configuration.certificatePath.isNull) {
      print(yellow(
          'skip signing step reason: Publisher provided but not Certificate Path'));
    } else {
      stdout.write(white('signing..  '));
      var signResults = _sign();

      if (!signResults.stdout
              .toString()
              .contains('Number of files successfully Signed: 1') &&
          signResults.stderr.toString().length > 0) {
        print(red(signResults.stdout));
        print(red(signResults.stderr));

        if (signResults.stdout
                .toString()
                .contains('Error: SignerSign() failed.') &&
            !_configuration.publisher.isNull) {
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

    _msixFiles.cleanTemporaryFiles();

    print('');
    print(green('Msix installer created in:'));
    print(blue('${_configuration.buildFilesFolder}'.replaceAll('/', r'\')));

    if (_configuration.isUsingTestCertificate) printTestCertificateHelp();
  }

  ProcessResult _generatePRI() {
    var msixPath =
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix';
    var makepriPath =
        '${_configuration.msixToolkitPath()}/Redist.${_configuration.architecture}/makepri.exe';

    if (File(msixPath).existsSync()) File(msixPath).deleteSync();

    var result = Process.runSync(makepriPath, [
      'createconfig',
      '/cf',
      '${_configuration.buildFilesFolder}\\priconfig.xml',
      '/dq',
      'en-US',
      '/o'
    ]);

    if (result.stderr.toString().length > 0) {
      print(red(result.stdout));
      print(red(result.stderr));
      exit(0);
    } else if (result.exitCode != 0) {
      print(red(result.stdout));
      exit(0);
    }

    result = Process.runSync(makepriPath, [
      'new',
      '/cf',
      '${_configuration.buildFilesFolder}\\priconfig.xml',
      '/pr',
      _configuration.buildFilesFolder,
      '/mn',
      '${_configuration.buildFilesFolder}\\AppxManifest.xml',
      '/of',
      '${_configuration.buildFilesFolder}\\resources.pri',
      '/o',
    ]);

    var priconfig = File('${_configuration.buildFilesFolder}/priconfig.xml');
    if (priconfig.existsSync()) priconfig.deleteSync();

    return result;
  }

  ProcessResult _pack() {
    var msixPath =
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix';
    var makeappxPath =
        '${_configuration.msixToolkitPath()}/Redist.${_configuration.architecture}/makeappx.exe';

    if (File(msixPath).existsSync()) File(msixPath).deleteSync();

    return Process.runSync(makeappxPath, [
      'pack',
      '/v',
      '/o',
      '/d',
      _configuration.buildFilesFolder,
      '/p',
      msixPath,
    ]);
  }

  ProcessResult _sign() {
    var signtoolPath =
        '${_configuration.msixToolkitPath()}/Redist.${_configuration.architecture}/signtool.exe';

    if (extension(_configuration.certificatePath!) == '.pfx') {
      return Process.runSync(signtoolPath, [
        'sign',
        '/fd',
        'SHA256',
        '/a',
        '/f',
        _configuration.certificatePath!,
        '/p',
        _configuration.certificatePassword!,
        '/tr',
        'http://timestamp.digicert.com',
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix',
      ]);
    } else {
      return Process.runSync(signtoolPath, [
        'sign',
        '/fd',
        'SHA256',
        '/a',
        _configuration.certificatePath!,
        '${_configuration.buildFilesFolder}\\${_configuration.appName}.msix',
      ]);
    }
  }
}
