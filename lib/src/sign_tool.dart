import 'dart:convert';
import 'dart:io';
import 'package:cli_util/cli_logging.dart' show Logger;
import 'package:console/console.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' show extension, basename;
import 'extensions.dart';
import 'configuration.dart';

var _publisherRegex = RegExp(
    '(CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID.(0|[1-9][0-9]*)(.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")(, ((CN|L|O|OU|E|C|S|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID.(0|[1-9][0-9]*)(.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")))*');

/// Handles the certificate sign functionality
class SignTool {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// get the certificate "Subject" for the Publisher value
  Future<void> getCertificatePublisher() async {
    _logger.trace('getting certificate publisher');

    var subject = '';

    if (_config.signToolOptions != null) {
      if (_config.signToolOptions!.containsArgument('/sha1')) {
        subject = await _getCertificateSubjectByThumbprint();
      } else if (_config.signToolOptions!.containsArguments(['/n', '/r'])) {
        subject = await _getCertificateSubjectBySubject();
      } else if (_config.signToolOptions!.containsArgument('/i')) {
        subject = await _getCertificateSubjectByIssuer();
      }
    } else if (_config.certificatePath != null &&
        extension(_config.certificatePath!).toLowerCase() == '.pfx') {
      subject = await _getPfxCertificateSubject();
    }

    if (subject.isNotEmpty) {
      _config.publisher = subject;
    }

    if (_config.publisher != null && _config.publisher!.isNotEmpty) {
      _checkCertificateSubject(_config.publisher!);
    } else {
      _failToGetCertificateSubject();
    }
  }

  /// prints useful information on the Publisher value messing
  /// and exit the program
  void _failToGetCertificateSubject() {
    _logger.stdout('could not find the Publisher value.'.red);
    _logger.stdout(
        'you must provide the Publisher value at "msix_config: publisher" in the pubspec.yaml file'
            .red);
    _logger.stdout(
        'the Publisher is the certificate "Subject" in this exact format: "CN=Contoso Software, O=Contoso Corporation, C=US"');
    _logger.stdout('see where you can found your certificate Subject:');
    _logger.stdout(
        'https://user-images.githubusercontent.com/946652/198945956-ec2ca7f2-36e9-4dfc-959b-48bcd191d82d.png'
            .blue);
    exit(-1);
  }

  String _getSignToolOptionsArgumentValue(String searchArgName) {
    var argumentIndex = _config.signToolOptions!.indexWhere(
        (argument) => argument.toLowerCase().trim() == searchArgName);

    /// return argument value
    return _config.signToolOptions![argumentIndex + 1];
  }

  void _checkCertificateSubject(String subject) {
    if (subject.isNotEmpty && !_publisherRegex.hasMatch(subject)) {
      throw 'invalid certificate subject: $subject';
    }
  }

  Future<ProcessResult> _executePowershellCommand(String command) async {
    return await Process.run(
        'powershell.exe', ['-NoProfile', '-NonInteractive', command],
        stdoutEncoding: utf8, stderrEncoding: utf8);
  }

  Future<String> _getInstalledCertificateSubject(String searchCondition) async {
    var certificateDetailsProcess = await _executePowershellCommand(
        "dir -Recurse cert: | where {$searchCondition} | select -expandproperty Subject -First 1");

    certificateDetailsProcess.exitOnError();

    var subject = (certificateDetailsProcess.stdout as String).trim();

    return subject;
  }

  Future<String> _getCertificateSubjectByThumbprint() async {
    _logger.trace('getting certificate "Subject" by certificate thumbprint');

    var thumbprintValue = _getSignToolOptionsArgumentValue('/sha1');
    var subject = await _getInstalledCertificateSubject(
        "\$_.Thumbprint -eq \"$thumbprintValue\"");

    return subject;
  }

  Future<String> _getCertificateSubjectBySubject() async {
    _logger.trace('getting certificate "Subject" by certificate Subject');

    var subjectValue = _getSignToolOptionsArgumentValue('/n');
    var subject = await _getInstalledCertificateSubject(
        "\$_.Subject –like \"*$subjectValue*\"");

    return subject;
  }

  Future<String> _getCertificateSubjectByIssuer() async {
    _logger.trace('getting certificate "Subject" by certificate Issuer');

    var subjectValue = _getSignToolOptionsArgumentValue('/i');
    var subject = await _getInstalledCertificateSubject(
        "\$_.Issuer –like \"*$subjectValue*\"");

    return subject;
  }

  Future<String> _getPfxCertificateSubject() async {
    _logger.trace('getting pfx certificate Subject');

    var powershellSubjectOutputFilePath =
        "${_config.msixAssetsPath}/subject.txt";

    var certificateDetailsProcess = await _executePowershellCommand(
        "(Get-PfxData -FilePath \"${_config.certificatePath}\" -Password \$(ConvertTo-SecureString -String \"${_config.certificatePassword}\" -AsPlainText -Force)).EndEntityCertificates[0] | Format-List -Property Subject | Out-File -NoNewLine -Width 8192 -Encoding UTF8 -FilePath \"$powershellSubjectOutputFilePath\"");

    certificateDetailsProcess.exitOnError();

    var powershellSubjectOutputFile = File(powershellSubjectOutputFilePath);

    if (!await powershellSubjectOutputFile.exists()) {
      throw 'cannot get PFX certificate subject'.red;
    }

    var subjectRow = await powershellSubjectOutputFile.readAsString();
    await powershellSubjectOutputFile.deleteIfExists();

    String subject = subjectRow
        .substring(subjectRow.indexOf(':') + 1, subjectRow.length)
        .trim();

    return subject;
  }

  /// Use Powershell to install the test certificate
  /// if needed and if the user want to.
  Future<void> installCertificate() async {
    var getInstalledCertificate = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      "dir Cert:\\CurrentUser\\Root | Where-Object { \$_.Subject -eq  '${_config.publisher}'}"
    ]);

    getInstalledCertificate.exitOnError();

    var isCertificateNotInstalled =
        getInstalledCertificate.stdout.toString().isNullOrEmpty;

    if (isCertificateNotInstalled) {
      _logger.trace('installing certificate');
      _logger.stdout('');

      var installCertificate = await readInput(
          'Do you want to install the certificate: "${basename(File(_config.certificatePath!).path)}" ?'
                  .emphasized +
              ' (y/N) '.gray);

      if (installCertificate.toLowerCase().trim() == 'y') {
        // create installCertificate.ps1 file
        var installCertificateScript =
            'Import-PfxCertificate -FilePath "${_config.certificatePath}" -Password (ConvertTo-SecureString -String "${_config.certificatePassword}" -AsPlainText -Force) -CertStoreLocation Cert:\\LocalMachine\\Root';
        var installCertificateScriptPath =
            '${_config.msixAssetsPath}/installCertificate.ps1';
        await File(installCertificateScriptPath)
            .writeAsString(installCertificateScript);

        // then execute it with admin privileges
        var importCertificate = await Process.run('powershell.exe', [
          '-NoProfile',
          '-NonInteractive',
          'Start-Process powershell -ArgumentList "$installCertificateScriptPath" -Wait -Verb runAs -WindowStyle Hidden'
        ]);

        await File(installCertificateScriptPath).deleteIfExists();

        if (importCertificate.exitCode != 0) {
          var error = importCertificate.stderr.toString();
          if (error.contains('was canceled by the user')) {
            _logger.stderr('the certificate installation was canceled'.red);
          } else {
            throw error;
          }
        } else {
          _logger.stdout('the certificate installed successfully '.green);
        }
      }
    }
  }

  /// Sign the MSIX file with the certificate
  Future<void> sign() async {
    _logger.trace('signing');

    var signtoolPath =
        '${_config.msixToolkitPath}/Redist.${_config.architecture}/signtool.exe';
    List<String> signtoolOptions = ['/v'];

    if (_config.signToolOptions != null &&
        _config.signToolOptions!.isNotEmpty) {
      signtoolOptions = _config.signToolOptions!;
    } else if (_config.certificatePath != null) {
      switch (extension(_config.certificatePath!).toLowerCase()) {
        case '.pfx':
          signtoolOptions.addAll([
            '/fd',
            'SHA256',
            '/f',
            _config.certificatePath!,
            '/p',
            _config.certificatePassword!
          ]);
          break;
        default:
          signtoolOptions.addAll([
            '/a',
            '/fd',
            'SHA256',
            '/f',
            _config.certificatePath!,
          ]);
      }

      signtoolOptions.addAll(['/tr', 'http://timestamp.digicert.com']);
    }

    var isFullSigntoolCommand =
        signtoolOptions[0].toLowerCase().contains('signtool');

    ProcessResult signProcess = await Process.run(
        isFullSigntoolCommand ? signtoolOptions[0] : signtoolPath, [
      if (!isFullSigntoolCommand) 'sign',
      ...signtoolOptions.skip(isFullSigntoolCommand ? 1 : 0),
      _config.msixPath,
    ]);

    signProcess.exitOnError();
  }
}
