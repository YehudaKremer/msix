import 'dart:io';
import 'dart:convert' show HtmlEscape;
import 'package:cli_util/cli_logging.dart';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

extension StringValidations on String? {
  bool get isNull => this == null;
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension StringExtensions on String {
  String get emphasized => '${Ansi(true).bold}${this}${Ansi(true).none}';
  String get green => '${Ansi(true).green}${this}${Ansi(true).none}';
  String get blue => '${Ansi(true).blue}${this}${Ansi(true).none}';
  String get red => '${Ansi(true).red}${this}${Ansi(true).none}';
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
