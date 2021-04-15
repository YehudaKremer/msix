import 'dart:io';
import 'package:path/path.dart';
import 'extensions.dart';
import 'injector.dart';
import 'log.dart';
import 'configuration.dart';

class Signtool {
  static void sign() {
    Log.startTask('signing');
    final config = injector.get<Configuration>();

    if (config.certificatePath.isNull) {
      Log.warn(
          'signing with TEST certificate, reason: Publisher provided but not Certificate Path');
    } else {
      var signtoolPath = '${config.msixToolkitPath()}/Redist.${config.architecture}/signtool.exe';

      ProcessResult signResults;

      if (extension(config.certificatePath!) == '.pfx') {
        signResults = Process.runSync(signtoolPath, [
          'sign',
          '/fd',
          'SHA256',
          '/a',
          '/f',
          config.certificatePath!,
          '/p',
          config.certificatePassword!,
          '/tr',
          'http://timestamp.digicert.com',
          if (config.debugSigning) '/debug',
          '${config.buildFilesFolder}\\${config.appName}.msix',
        ]);
      } else {
        signResults = Process.runSync(signtoolPath, [
          'sign',
          '/fd',
          'SHA256',
          '/a',
          '/f',
          config.certificatePath!,
          if (config.debugSigning) '/debug',
          '${config.buildFilesFolder}\\${config.appName}.msix',
        ]);
      }

      if (!signResults.stdout.toString().contains('Number of files successfully Signed: 1') &&
          signResults.stderr.toString().length > 0) {
        Log.error(signResults.stdout);
        Log.error(signResults.stderr);

        if (signResults.stdout.toString().contains('Error: SignerSign() failed.') &&
            !config.publisher.isNull) {
          Log.printCertificateSubjectHelp();
        }

        exit(0);
      }

      if (config.isUsingTestCertificate) {
        Log.warn(' *no certificate was specified, using TEST certificate');
      }

      Log.completeTask();
    }
  }
}
