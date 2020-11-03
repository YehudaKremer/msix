import 'package:ansicolor/ansicolor.dart';

String msixPackagePath = '';
const String iconsFolderName = 'icons';
String defaultsIconsFolderPath() => '${msixPackagePath}assets/icons';
String vcLibsFolderPath() => '${msixPackagePath}assets/VCLibs';
String msixToolkitPath() => '${msixPackagePath}assets/MSIX-Toolkit';
const String defaultIconsBackgroundColor = '#ffffff';
const String defaultMsixVersion = '1.0.0.0';
String defaultCertificatePath() => '${msixPackagePath}assets/test_certificate.pfx';
const String defaultCertificatePassword = '1234';
const String defaultCertificateSubject = 'CN=Msix Testing, O=Msix Testing Corporation, C=US';
const String defaultArchitecture = 'x64';
final AnsiPen white = AnsiPen()..white(bold: true);
final AnsiPen red = AnsiPen()..red(bold: true);
final AnsiPen green = AnsiPen()..green(bold: true);
final AnsiPen yellow = AnsiPen()..yellow(bold: true);
