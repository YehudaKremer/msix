import 'dart:io';
import 'package:path/path.dart';
import 'extensions.dart';
import 'log.dart';
import 'configuration.dart';

class Signtool {
  Configuration _config;

  Signtool(this._config);

  void sign() {
    Log.startTask('signing');
    if (_config.certificatePath.isNull) {
      Log.warn(
          'signing with TEST certificate, reason: Publisher provided but not Certificate Path');
    } else {
      var signtoolPath = '${_config.msixToolkitPath()}/Redist.${_config.architecture}/signtool.exe';

      ProcessResult signResults;

      if (extension(_config.certificatePath!) == '.pfx') {
        signResults = Process.runSync(signtoolPath, [
          'sign',
          '/fd',
          'SHA256',
          '/a',
          '/f',
          _config.certificatePath!,
          '/p',
          _config.certificatePassword!,
          '/tr',
          'http://timestamp.digicert.com',
          if (_config.debugSigning) '/debug',
          '${_config.buildFilesFolder}\\${_config.appName}.msix',
        ]);
      } else {
        signResults = Process.runSync(signtoolPath, [
          'sign',
          '/fd',
          'SHA256',
          '/a',
          '/f',
          _config.certificatePath!,
          if (_config.debugSigning) '/debug',
          '${_config.buildFilesFolder}\\${_config.appName}.msix',
        ]);
      }

      if (!signResults.stdout.toString().contains('Number of files successfully Signed: 1') &&
          signResults.stderr.toString().length > 0) {
        Log.error(signResults.stdout);
        Log.error(signResults.stderr);

        if (signResults.stdout.toString().contains('Error: SignerSign() failed.') &&
            !_config.publisher.isNull) {
          Log.printCertificateSubjectHelp();
        }

        exit(0);
      }

      if (_config.isUsingTestCertificate) {
        Log.warn(' *no certificate was specified, using TEST certificate');
      }

      Log.completeTask();
    }
  }
}
