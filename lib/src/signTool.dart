import 'dart:io';
import 'package:msix/src/extensions.dart';
import 'package:path/path.dart';
import 'configuration.dart';
import 'package:cli_util/cli_logging.dart';
import 'extensions.dart';

var _publisherRegex = RegExp(
    '(CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")(, ((CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")))*');

/// Handles signing operations
class SignTool {
  Configuration _config;
  Logger _logger;

  SignTool(this._config, this._logger);

  /// Use the certutil.exe tool to detect the certificate publisher name (Subject)
  Future<void> getCertificatePublisher() async {
    _logger.trace('getting certificate publisher');

    var certificateDetails = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      "(Get-PfxData -FilePath \"${_config.certificatePath}\" -Password \$(ConvertTo-SecureString -String \"${_config.certificatePassword}\" -AsPlainText -Force)).EndEntityCertificates[0] | Format-List -Property Subject"
    ]);

    if (certificateDetails.exitCode != 0) {
      throw certificateDetails.stderr;
    }

    var subjectRow = certificateDetails.stdout.toString();

    if (!_publisherRegex.hasMatch(subjectRow)) {
      throw 'Invalid certificate subject: $subjectRow';
    }

    try {
      _config.publisher = subjectRow
          .substring(subjectRow.indexOf(':') + 1, subjectRow.length)
          .trim();
    } catch (e) {
      _logger.stderr('Error while getting certificate publisher');
      throw e;
    }
  }

  /// Use the certutil.exe tool to install the certificate on the local machine
  /// this helps to avoid the need to install the certificate by hand
  Future<void> installCertificate() async {
    var getInstalledCertificate = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      "dir Cert:\\CurrentUser\\Root | Where-Object { \$_.Subject -eq  '${_config.publisher}'}"
    ]);

    if (getInstalledCertificate.exitCode != 0) {
      throw getInstalledCertificate.stderr;
    }

    var isCertificateNotInstalled =
        getInstalledCertificate.stdout.toString().isNullOrEmpty;

    if (isCertificateNotInstalled) {
      _logger.trace('installing certificate');

      var isAdminCheck = await Process.run('net', ['session']);

      if (isAdminCheck.stderr.toString().contains('Access is denied')) {
        throw 'To install the test certificate run the command "flutter pub run msix:create" as administrator';
      }

      var result = await Process.run('certutil', [
        '-f',
        '-enterprise',
        '-p',
        _config.certificatePassword!,
        '-importpfx',
        'root',
        _config.certificatePath!
      ]);

      if (result.exitCode != 0) {
        throw result.stdout;
      }
    }
  }

  /// Sign the created msix installer with the certificate
  Future<void> sign() async {
    _logger.trace('signing');

    if (!_config.certificatePath.isNull || _config.signToolOptions != null) {
      var signtoolPath =
          '${_config.msixToolkitPath()}/Redist.${_config.architecture}/signtool.exe';

      List<String> signtoolOptions = [];

      if (_config.signToolOptions != null) {
        signtoolOptions = _config.signToolOptions!;
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

      ProcessResult result = await Process.run(signtoolPath, [
        'sign',
        ...signtoolOptions,
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix',
      ]);

      if (result.exitCode != 0) {
        throw result.stdout;
      }
    }
  }
}
