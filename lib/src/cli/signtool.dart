import 'dart:io';
import 'package:path/path.dart';
import '../utils/extensions.dart';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class Signtool {
  static void sign() {
    Log.taskStarted('signing');
    final config = injector.get<Configuration>();

    if (!config.certificatePath.isNull) {
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
        Log.error(signResults.stdout, andExit: false);
        Log.error(signResults.stderr, andExit: false);

        if (signResults.stdout.toString().contains('Error: SignerSign() failed.') &&
            !config.publisher.isNull) {
          Log.printCertificateSubjectHelp();
        }

        exit(0);
      }

      Log.taskCompleted();
    }
  }
}
