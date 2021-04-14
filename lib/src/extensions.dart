import 'package:args/args.dart';

extension StringValidations on String? {
  bool get isNull => this == null;
}

extension ArgResultsReader on ArgResults {
  String? read(String key, {String? fallback}) =>
      this[key] != null && this[key].toString().length > 0 ? this[key] : fallback;
}
