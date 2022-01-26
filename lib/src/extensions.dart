import 'dart:ffi';
import 'dart:io';

import 'package:args/args.dart';

extension StringValidations on String? {
  bool get isNull => this == null;
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension ArgResultsReader on ArgResults {
  String? read(String key) => this.wasParsed(key) ? this[key] : null;
}

extension FileSystemEntityExtensions on FileSystemEntity {
  Future<FileSystemEntity?> deleteIfExists({bool recursive = false}) async =>
      await this.exists() ? this.delete(recursive: recursive) : Future.value();
}
