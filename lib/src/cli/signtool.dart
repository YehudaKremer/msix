import 'dart:io';
import 'package:path/path.dart';
import '../utils/extensions.dart';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class Signtool {
  static void installTestCertificate() {
    const taskName = 'installing test certificate';
    Log.startingTask(taskName);
    final config = injector.get<Configuration>();

    var installedCertificatesList =
        Process.runSync('certutil', ['-store', 'root']);

    if (!installedCertificatesList.stdout
        .toString()
        .contains(defaultPublisher)) {
      var isAdminCheck = Process.runSync('net', ['session']);

      if (isAdminCheck.stderr.toString().contains('Access is denied')) {
        Log.errorAndExit(
            'to install the test certificate, you need to run this As-Admin once');
      }

      var result = Process.runSync('certutil', [
        '-f',
        '-enterprise',
        '-p',
        '1234',
        '-importpfx',
        'root',
        config.certificatePath!
      ]);

      if (result.stderr.toString().length > 0) {
        Log.error(result.stdout);
        Log.errorAndExit(result.stderr);
      } else if (result.exitCode != 0) {
        Log.errorAndExit(result.stdout);
      }
    }

    Log.taskCompleted(taskName);
  }

  static void sign() {
    const taskName = 'signing';
    Log.startingTask(taskName);
    final config = injector.get<Configuration>();

    if (!config.certificatePath.isNull || config.signtoolOptions != null) {
      var signtoolPath =
          '${config.msixToolkitPath()}/Redist.${config.architecture}/signtool.exe';

      List<String> signtoolOptions = [];

      if (config.signtoolOptions != null) {
        signtoolOptions = config.signtoolOptions!;
      } else {
        signtoolOptions = [
          '/v',
          '/fd',
          'SHA256',
          '/a',
          '/f',
          config.certificatePath!,
          if (extension(config.certificatePath!) == '.pfx') '/p',
          if (extension(config.certificatePath!) == '.pfx')
            config.certificatePassword!,
          '/tr',
          'http://timestamp.digicert.com'
        ];
      }

      if (!signtoolOptions.contains('/fd')) {
        Log.error(
            'signtool need "/fb" (file digest algorithm) option, for example: "/fd SHA256", more details:');
        Log.link(
            'https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe#sign-command-options');
        exit(0);
      }

      ProcessResult signResults = Process.runSync(signtoolPath, [
        'sign',
        ...signtoolOptions,
        if (config.debugSigning) '/debug',
        '${config.buildFilesFolder}\\${config.appName}.msix',
      ]);

      if (!signResults.stdout
              .toString()
              .contains('Number of files successfully Signed: 1') &&
          signResults.stderr.toString().length > 0) {
        Log.error(signResults.stdout);
        Log.error(signResults.stderr);

        if (config.signtoolOptions == null &&
            signResults.stdout
                .toString()
                .contains('Error: SignerSign() failed.') &&
            !config.publisher.isNull) {
          Log.printCertificateSubjectHelp();
        }

        exit(0);
      }
    }

    Log.taskCompleted(taskName);
  }
}
