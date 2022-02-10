import 'dart:io';
import 'package:cli_dialog/cli_dialog.dart' show CLI_Dialog;
import 'package:cli_util/cli_logging.dart' show Logger;
import 'package:path/path.dart' show extension, basename;
import 'extensions.dart';
import 'configuration.dart';

var _publisherRegex = RegExp(
    '(CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")(, ((CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")))*');

/// Handles the certificate sign functionality
class SignTool {
  Configuration _config;
  Logger _logger;

  SignTool(this._config, this._logger);

  /// Use Powershell script to get the Publisher ("Subject") of the certificate
  Future<void> getCertificatePublisher() async {
    _logger.trace('getting certificate publisher');

    var certificateDetailsProcess = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      "(Get-PfxData -FilePath \"${_config.certificatePath}\" -Password \$(ConvertTo-SecureString -String \"${_config.certificatePassword}\" -AsPlainText -Force)).EndEntityCertificates[0] | Format-List -Property Subject"
    ]);

    if (certificateDetailsProcess.exitCode != 0) {
      _logger.stderr(certificateDetailsProcess.stdout);
      throw certificateDetailsProcess.stderr;
    }

    var subjectRow = certificateDetailsProcess.stdout.toString();

    if (!_publisherRegex.hasMatch(subjectRow)) {
      throw 'invalid certificate subject: $subjectRow';
    }

    _config.publisher = subjectRow
        .substring(subjectRow.indexOf(':') + 1, subjectRow.length)
        .trim();
  }

  /// Use Powershell to install the test certificate
  /// if needed and if the user want to.
  Future<void> installCertificate() async {
    var getInstalledCertificate = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      "dir Cert:\\CurrentUser\\Root | Where-Object { \$_.Subject -eq  '${_config.publisher}'}"
    ]);

    if (getInstalledCertificate.exitCode != 0) {
      _logger.stderr(getInstalledCertificate.stdout);
      throw getInstalledCertificate.stderr;
    }

    var isCertificateNotInstalled =
        getInstalledCertificate.stdout.toString().isNullOrEmpty;

    if (isCertificateNotInstalled) {
      _logger.trace('installing certificate');

      var isRunningAsAdmin = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
      ]);

      if (isRunningAsAdmin.exitCode != 0) {
        _logger.stderr(isRunningAsAdmin.stdout);
        throw isRunningAsAdmin.stderr;
      }

      _logger.stdout('');
      final dialog = CLI_Dialog(booleanQuestions: [
        [
          'Do you want to install the certificate: "${basename(File(_config.certificatePath!).path)}" ?',
          'install'
        ]
      ]);
      final wantToInstallCertificate = dialog.ask()['install'];

      if (wantToInstallCertificate) {
        // create installCertificate.ps1 file
        var installCertificateScript =
            'Import-PfxCertificate -FilePath \"${_config.certificatePath}\" -Password (ConvertTo-SecureString -String \"${_config.certificatePassword}\" -AsPlainText -Force) -CertStoreLocation Cert:\\LocalMachine\\Root';
        var installCertificateScriptPath =
            '${_config.msixAssetsPath}/installCertificate.ps1';
        await File(installCertificateScriptPath)
            .writeAsString(installCertificateScript);

        // then execute it with admin privileges
        var importCertificate = await Process.run('powershell.exe', [
          '-NoProfile',
          '-NonInteractive',
          'Start-Process powershell -ArgumentList \"$installCertificateScriptPath\" -Wait -Verb runAs -WindowStyle Hidden'
        ]);

        await File(installCertificateScriptPath).deleteIfExists();

        if (importCertificate.exitCode != 0) {
          var error = importCertificate.stderr.toString();
          if (error.contains('was canceled by the user')) {
            _logger.stderr(
                'the certificate installation was canceled'.red.emphasized);
          } else {
            throw error;
          }
        } else {
          _logger.stdout(
              'the certificate installed successfully '.green.emphasized);
        }
      }
    }
  }

  /// Sign the MSIX file with the certificate
  Future<void> sign() async {
    _logger.trace('signing');

    if (!_config.certificatePath.isNull || _config.signToolOptions != null) {
      var signtoolPath =
          '${_config.msixToolkitPath}/Redist.${_config.architecture}/signtool.exe';

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

      ProcessResult signProcess = await Process.run(signtoolPath, [
        'sign',
        ...signtoolOptions,
        _config.msixPath,
      ]);

      if (signProcess.exitCode != 0) {
        _logger.stderr(signProcess.stdout);
        throw signProcess.stderr;
      }
    }
  }
}
