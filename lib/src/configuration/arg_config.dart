//TODO add comments
class ArgConfig {
  final String? abbr;
  final String? help;
  final String? valueHelp;
  final bool? hide;
  final bool? negatable;
  final Iterable<String>? allowed;

  const ArgConfig(
      {this.abbr,
      this.help,
      this.valueHelp,
      this.hide = false,
      this.negatable = false,
      this.allowed});
}
