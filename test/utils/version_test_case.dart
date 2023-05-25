class VersionTestCase {
  final String testName;
  final String versionString;
  final bool autoVersionWithBuildNumber;
  final String? result;
  const VersionTestCase(
      {required this.testName,
      required this.versionString,
      required this.autoVersionWithBuildNumber,
      required this.result});
}
