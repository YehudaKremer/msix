import 'package:args/args.dart';

extension StringValidations on String? {
  bool get isNull => this == null;
}

extension ArgResultsReader on ArgResults {
  String? read(String key) => this.wasParsed(key) ? this[key] : null;
}
