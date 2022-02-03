import 'dart:io';
import 'package:msix/src/extensions.dart';
import 'package:path/path.dart';
import 'configuration.dart';
import 'log.dart';

var _publisherRegex = RegExp(
    '(CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")(, ((CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID\.(0|[1-9][0-9]*)(\.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")))*');

/// Handles signing operations
class SignTool {
  Configuration _config;
  Log _log;

  SignTool(this._config, this._log);

  /// Use the certutil.exe tool to detect the certificate publisher name (Subject)
  Future<void> getCertificatePublisher() async {
    const taskName = 'getting certificate publisher';
    _log.startingTask(taskName);

    var result = await Process.run('certutil',
        ['-dump', '-p', _config.certificatePassword!, _config.certificatePath!],
        runInShell: true);

    if (result.exitCode != 0) {
      throw result.stdout;
    }

    try {
      var subjectRow = result.stdout
          .toString()
          .split('\n')
          .lastWhere((row) => _publisherRegex.hasMatch(row));

      _config.publisher = subjectRow
          .substring(subjectRow.indexOf(':') + 1, subjectRow.length)
          .trim();
    } catch (e) {
      _log.error('Error while getting certificate publisher');
      throw e;
    }

    _log.taskCompleted(taskName);
  }

  /// Use the certutil.exe tool to install the certificate on the local machine
  /// this helps to avoid the need to install the certificate by hand
  Future<void> installCertificate() async {
    const taskName = 'installing certificate';
    _log.startingTask(taskName);

    var installedCertificatesList =
        await Process.run('certutil', ['-store', 'root']);

    if (!installedCertificatesList.stdout
        .toString()
        .contains(_config.publisher!)) {
      var isAdminCheck = await Process.run('net', ['session']);

      if (isAdminCheck.stderr.toString().contains('Access is denied')) {
        throw 'to install the certificate "${_config.certificatePath}" you need to "Run as administrator" once';
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

    _log.taskCompleted(taskName);
  }

  /// Sign the created msix installer with the certificate
  Future<void> sign() async {
    const taskName = 'signing';
    _log.startingTask(taskName);

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
        if (_config.debugSigning) '/debug',
        '${_config.outputPath ?? _config.buildFilesFolder}\\${_config.outputName ?? _config.appName}.msix',
      ]);

      if (result.exitCode != 0) {
        throw result.stdout;
      }
    }

    _log.taskCompleted(taskName);
  }
}
