import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cli_util/cli_logging.dart';
import 'package:console/console.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'method_extensions.dart';
import 'configuration.dart';

RegExp _publisherRegex = RegExp(
    '(CN|L|O|OU|E|C|S|ST|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID.(0|[1-9][0-9]*)(.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")(, ((CN|L|O|OU|E|C|S|ST|STREET|T|G|I|SN|DC|SERIALNUMBER|(OID.(0|[1-9][0-9]*)(.(0|[1-9][0-9]*))+))=(([^,+="<>#;])+|".*")))*');

/// Handles the certificate sign functionality
class SignTool {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// get the certificate "Subject" for the Publisher value
  Future<void> getCertificatePublisher() async {
    _logger.trace('getting certificate publisher');

    if (_config.publisher.isNullOrEmpty || _config.isTestCertificate) {
      String subject = '';

      if (isCustomSignCommand(_config.signToolOptions)) {
        if (_config.signToolOptions!.containsArgument('/sha1')) {
          subject = await _getCertificateSubjectByThumbprint();
        } else if (_config.signToolOptions!.containsArguments(['/n', '/r'])) {
          subject = await _getCertificateSubjectBySubject();
        } else if (_config.signToolOptions!.containsArgument('/i')) {
          subject = await _getCertificateSubjectByIssuer();
        } else if (_config.signToolOptions!.containsArgument('/f')) {
          subject = await _getCertificateSubjectByFile(true);
        }
      } else if (_config.certificatePath != null &&
          _config.certificatePath!.isNotEmpty) {
        subject = await _getCertificateSubjectByFile(false);
      }

      if (subject.isNotEmpty) {
        _config.publisher = subject;
      }
    }

    if (_config.publisher.isNullOrEmpty) {
      _failToGetCertificateSubject();
    } else {
      _checkCertificateSubject(_config.publisher!);
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
    int argumentIndex = _config.signToolOptions!.indexWhere(
        (argument) => argument.toLowerCase().trim() == searchArgName);

    /// return argument value
    return _config.signToolOptions![argumentIndex + 1];
  }

  void _checkCertificateSubject(String subject) {
    if (subject.isNotEmpty && !_publisherRegex.hasMatch(subject)) {
      throw 'invalid certificate subject: $subject';
    }
  }

  Future<ProcessResult> _executePowershellCommand(String command) async =>
      await Process.run(
          'powershell.exe', ['-NoProfile', '-NonInteractive', command],
          stdoutEncoding: utf8, stderrEncoding: utf8)
        ..exitOnError();

  Future<String> _getInstalledCertificateSubject(String searchCondition) async {
    ProcessResult certificateDetailsProcess = await _executePowershellCommand(
        "\$env:PSModulePath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine');dir -Recurse cert: | where {$searchCondition} | select -expandproperty Subject -First 1");

    String subject = (certificateDetailsProcess.stdout as String).trim();

    return subject;
  }

  Future<String> _getCertificateSubjectByThumbprint() async {
    _logger.trace('getting certificate "Subject" by certificate thumbprint');

    String thumbprintValue = _getSignToolOptionsArgumentValue('/sha1');
    String subject = await _getInstalledCertificateSubject(
        "\$_.Thumbprint -eq \"$thumbprintValue\"");

    return subject;
  }

  Future<String> _getCertificateSubjectBySubject() async {
    _logger.trace('getting certificate "Subject" by certificate Subject');

    String subjectValue = _getSignToolOptionsArgumentValue('/n');
    String subject = await _getInstalledCertificateSubject(
        "\$_.Subject -like \"*$subjectValue*\"");

    return subject;
  }

  Future<String> _getCertificateSubjectByIssuer() async {
    _logger.trace('getting certificate "Subject" by certificate Issuer');

    String issuerValue = _getSignToolOptionsArgumentValue('/i');
    String subject = await _getInstalledCertificateSubject(
        "\$_.Issuer -like \"*$issuerValue*\"");

    return subject;
  }

  Future<String> _getCertificateSubjectByFile(bool fromSignToolOptions) async {
    _logger.trace('getting certificate "Subject" by file certificate');

    String filePathValue = fromSignToolOptions
        ? _getSignToolOptionsArgumentValue('/f')
        : _config.certificatePath!;
    String passwordValue = _config.certificatePassword ?? '';
    if (fromSignToolOptions &&
        _config.signToolOptions!.containsArgument('/p')) {
      passwordValue = _getSignToolOptionsArgumentValue('/p');
    }
    ProcessResult certificateDetailsProcess = await _executePowershellCommand(
        """new-object System.Security.Cryptography.X509Certificates.X509Certificate2("$filePathValue",
        "$passwordValue") | select -expandproperty Subject -First 1""");

    String subject = (certificateDetailsProcess.stdout as String).trim();

    return subject;
  }

  /// Use Powershell to install the test certificate
  /// if needed and if the user want to.
  Future<void> installCertificate() async {
    ProcessResult getInstalledCertificate =
        await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      "\$env:PSModulePath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine');dir Cert:\\CurrentUser\\Root | Where-Object { \$_.Subject -eq  '${_config.publisher}'}"
    ])
          ..exitOnError();

    bool isCertificateNotInstalled =
        getInstalledCertificate.stdout.toString().isNullOrEmpty;

    if (isCertificateNotInstalled) {
      _logger.trace('installing certificate');
      _logger.stdout('');

      String installCertificate = await readInput(
          'Do you want to install the certificate: "${basename(File(_config.certificatePath!).path)}" ?'
                  .emphasized +
              ' (y/N) '.gray);

      if (installCertificate.toLowerCase().trim() == 'y') {
        // create installCertificate.ps1 file
        String installCertificateScript =
            'Import-PfxCertificate -FilePath "${_config.certificatePath}" -Password (ConvertTo-SecureString -String "${_config.certificatePassword}" -AsPlainText -Force) -CertStoreLocation Cert:\\LocalMachine\\Root';
        String installCertificateScriptPath =
            p.join(_config.msixAssetsPath, 'installCertificate.ps1');
        await File(installCertificateScriptPath)
            .writeAsString(installCertificateScript);

        // then execute it with admin privileges
        ProcessResult importCertificate = await Process.run('powershell.exe', [
          '-NoProfile',
          '-NonInteractive',
          'Start-Process powershell -ArgumentList "$installCertificateScriptPath" -Wait -Verb runAs -WindowStyle Hidden'
        ]);

        await File(installCertificateScriptPath).deleteIfExists();

        if (importCertificate.exitCode != 0) {
          String error = importCertificate.stderr.toString();
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

    String signtoolPath = p.join(_config.msixToolkitPath, 'signtool.exe');
    List<String> signtoolOptions = _config.signToolOptions ?? ['/v'];

    if (isCustomSignCommand(_config.signToolOptions)) {
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

    bool isFullSigntoolCommand =
        signtoolOptions[0].toLowerCase().contains('signtool');

    // ignore: avoid_single_cascade_in_expression_statements
    await Process.run(
        isFullSigntoolCommand ? signtoolOptions[0] : signtoolPath, [
      if (!isFullSigntoolCommand) 'sign',
      ...signtoolOptions.skip(isFullSigntoolCommand ? 1 : 0),
      _config.msixPath,
    ])
      ..exitOnError();
  }

  static isCustomSignCommand(List<String>? signToolOptions) =>
      signToolOptions != null &&
      signToolOptions.isNotEmpty &&
      signToolOptions.containsArguments(['/sha1', '/n', '/r', '/i', '/f']);
}
