import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:msix/src/configuration.dart';
import 'package:msix/src/sign_tool.dart';
import 'package:test/test.dart';

final getIt = GetIt.instance;

void main() {
  getIt.registerSingleton<Logger>(Logger.standard());
  getIt.registerSingleton<Configuration>(Configuration([]));

  List<String>? originalSignToolOptions;
  String? originalCertificatePath;
  String? originalCertificatePassword;
  setUp(() {
    final config = getIt<Configuration>();
    originalSignToolOptions = config.signToolOptions;
    originalCertificatePath = config.certificatePath;
    originalCertificatePassword = config.certificatePassword;
  });

  tearDown(() {
    final config = getIt<Configuration>();
    config.signToolOptions = originalSignToolOptions;
    config.certificatePath = originalCertificatePath;
    config.certificatePassword = originalCertificatePassword;
  });

  group('`SignTool.signToolOptions` with null config sign tool options', () {
    final config = getIt<Configuration>();
    config.signToolOptions = null;
    config.certificatePassword = 'password1234';

    final signTool = SignTool();
    test('`.pfx` certificate', () {
      config.certificatePath = 'cert.pfx';
      final options = signTool.getSignToolOptions().join(' ');

      expect(options.contains('/v'), isTrue);
      expect(options.contains('/f ${config.certificatePath}'), isTrue);
      expect(options.contains('/p ${config.certificatePassword}'), isTrue);
      expect(options.contains('/fd SHA256'), isTrue);
      expect(options.contains('/tr http://timestamp.digicert.com'), isTrue);
      expect(options.contains('/td SHA256'), isTrue);
    });

    test('Non-`.pfx` certificate', () {
      config.certificatePath = 'cert.pem';
      final options = signTool.getSignToolOptions().join(' ');

      expect(options.contains('/v'), isTrue);
      expect(options.contains('/f ${config.certificatePath}'), isTrue);
      expect(options.contains('/a'), isTrue);
      expect(options.contains('/fd SHA256'), isTrue);
      expect(options.contains('/td SHA256'), isTrue);
      expect(options.contains('/tr http://timestamp.digicert.com'), isTrue);
    });
  });
}
