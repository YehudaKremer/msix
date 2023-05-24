class VersionTestCase {
  final String testName;
  final String versionString;
  final bool versionWithBuildNumber;
  final String? result;
  const VersionTestCase(
      {required this.testName,
      required this.versionString,
      required this.versionWithBuildNumber,
      required this.result});
}
