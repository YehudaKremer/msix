import 'dart:io';
import 'package:path/path.dart';
import '../utils/extensions.dart';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

class Signtool {
  static void getCertificatePublisher(bool withLogs) {
    const taskName = 'getting certificate publisher';
    Log.startingTask(taskName);
    final config = injector.get<Configuration>();

    var certificateDetails = Process.runSync('certutil',
        ['-dump', '-p', config.certificatePassword!, config.certificatePath!]);

    if (certificateDetails.stderr.toString().length > 0) {
      if (certificateDetails.stderr.toString().contains('password')) {
        Log.errorAndExit(
            'Fail to read the certificate details, check if the certificate password is correct');
      }
      Log.error(certificateDetails.stdout);
      Log.errorAndExit(certificateDetails.stderr);
    } else if (certificateDetails.exitCode != 0) {
      Log.errorAndExit(certificateDetails.stdout);
    }

    if (withLogs) Log.info('Certificate Details: ${certificateDetails.stdout}');

    try {
      var subjectRow = certificateDetails.stdout
          .toString()
          .split('\n')
          .lastWhere((row) =>
              !row.isNullOrEmpty &&
              (row.toLowerCase().contains('cn =') ||
                  row.toLowerCase().contains('cn=')));
      if (withLogs) Log.info('subjectRow: $subjectRow');
      config.publisher = subjectRow
          .substring(subjectRow.indexOf(':') + 1, subjectRow.length)
          .trim();
      if (withLogs) Log.info('config.publisher: ${config.publisher}');
    } catch (err, stackTrace) {
      if (!withLogs) getCertificatePublisher(true);
      Log.error(err.toString());
      if (withLogs)
        Log.warn(
            'This error happen when this package tried to read the certificate details,');
      if (withLogs)
        Log.warn(
            'please report it by pasting all this output (after deleting sensitive info) to:');
      if (withLogs) Log.link('https://github.com/YehudaKremer/msix/issues');
      Log.errorAndExit(stackTrace.toString());
    }

    Log.taskCompleted(taskName);
  }

  static void installCertificate() {
    const taskName = 'installing certificate';
    Log.startingTask(taskName);
    final config = injector.get<Configuration>();

    var installedCertificatesList =
        Process.runSync('certutil', ['-store', 'root']);

    if (!installedCertificatesList.stdout
        .toString()
        .contains(config.publisher!)) {
      var isAdminCheck = Process.runSync('net', ['session']);

      if (isAdminCheck.stderr.toString().contains('Access is denied')) {
        Log.errorAndExit(
            'to install the certificate "${config.certificatePath}" you need to "Run as administrator" once');
      }

      var result = Process.runSync('certutil', [
        '-f',
        '-enterprise',
        '-p',
        config.certificatePassword!,
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
        '${config.outputPath ?? config.buildFilesFolder}\\${config.outputName ?? config.appName}.msix',
      ]);

      if (config.debugSigning) Log.info(signResults.stdout.toString());

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
          Log.errorAndExit('signing error');
        }

        exit(0);
      }
    }

    Log.taskCompleted(taskName);
  }
}
