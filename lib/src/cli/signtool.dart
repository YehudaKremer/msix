import 'dart:io';
import 'package:path/path.dart';
import '../utils/extensions.dart';
import '../utils/injector.dart';
import '../utils/log.dart';
import '../configuration.dart';

var _publisherRegex = RegExp(
    '(CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")(, ((CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")))*');

class Signtool {
  static void getCertificatePublisher(bool withLogs) {
    const taskName = 'getting certificate publisher';
    Log.startingTask(taskName);
    final _config = injector.get<Configuration>();

    var certificateDetails = Process.runSync('certutil', [
      '-dump',
      '-p',
      _config.certificatePassword!,
      _config.certificatePath!
    ]);

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
          .lastWhere((row) => _publisherRegex.hasMatch(row));
      if (withLogs) Log.info('subjectRow: $subjectRow');
      _config.publisher = subjectRow
          .substring(subjectRow.indexOf(':') + 1, subjectRow.length)
          .trim();
      if (withLogs) Log.info('config.publisher: ${_config.publisher}');
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
    final _config = injector.get<Configuration>();

    var installedCertificatesList =
        Process.runSync('certutil', ['-store', 'root']);

    if (!installedCertificatesList.stdout
        .toString()
        .contains(_config.publisher!)) {
      var isAdminCheck = Process.runSync('net', ['session']);

      if (isAdminCheck.stderr.toString().contains('Access is denied')) {
        Log.errorAndExit(
            'to install the certificate "${_config.certificatePath}" you need to "Run as administrator" once');
      }

      var result = Process.runSync('certutil', [
        '-f',
        '-enterprise',
        '-p',
        _config.certificatePassword!,
        '-importpfx',
        'root',
        _config.certificatePath!
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
    final _config = injector.get<Configuration>();

    if (!_config.certificatePath.isNull || _config.signtoolOptions != null) {
      var signtoolPath =
          '${_config.msixToolkitPath()}/Redist.${_config.architecture}/signtool.exe';

      List<String> signtoolOptions = [];

      if (_config.signtoolOptions != null) {
        signtoolOptions = _config.signtoolOptions!;
      } else {
        signtoolOptions = [
          '/v',
          '/fd',
          'SHA256',
          '/a',
          '/f',
          _config.certificatePath!,
          if (extension(_config.certificatePath!) == '.pfx') '/p',
          if (extension(_config.certificatePath!) == '.pfx')
            _config.certificatePassword!,
          '/tr',
          'http://timestamp.digicert.com'
        ];
      }

      if (!signtoolOptions.contains('/fd')) {
        Log.error(
            'signtool need "/fb" (file digest algorithm) option, for example: "/fd SHA256", more details:');
        Log.link(
            'https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe#sign-command-options');
        exit(-1);
      }

      ProcessResult signResults = Process.runSync(signtoolPath, [
        'sign',
        ...signtoolOptions,
        if (_config.debugSigning) '/debug',
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix',
      ]);

      if (_config.debugSigning) Log.info(signResults.stdout.toString());

      if (!signResults.stdout
              .toString()
              .contains('Number of files successfully Signed: 1') &&
          signResults.stderr.toString().length > 0) {
        Log.error(signResults.stdout);
        Log.error(signResults.stderr);

        if (_config.signtoolOptions == null &&
            signResults.stdout
                .toString()
                .contains('Error: SignerSign() failed.') &&
            !_config.publisher.isNull) {
          Log.errorAndExit('signing error');
        }

        exit(-1);
      }
    }

    Log.taskCompleted(taskName);
  }
}
