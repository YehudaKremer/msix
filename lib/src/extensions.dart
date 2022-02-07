import 'dart:io';
import 'dart:convert' show HtmlEscape;
import 'package:args/args.dart';

extension StringValidations on String? {
  bool get isNull => this == null;
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension StringConversions on String? {
  String? toHtmlEscape() => this != null ? HtmlEscape().convert(this!) : null;
}

extension ArgResultsReader on ArgResults {
  String? read(String key) => this.wasParsed(key) ? this[key] : null;
}

extension FileSystemEntityExtensions on FileSystemEntity {
  Future<FileSystemEntity?> deleteIfExists({bool recursive = false}) async =>
      await this.exists() ? this.delete(recursive: recursive) : Future.value();
}
