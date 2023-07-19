// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

extension StringValidations on String? {
  bool get isNull => this == null;
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

/// Used for colored logs
extension StringExtensions on String {
  String get emphasized => '${Ansi(true).bold}${this}${Ansi(true).none}';
  String get green => '${Ansi(true).green}${this}${Ansi(true).none}';
  String get blue => '${Ansi(true).blue}${this}${Ansi(true).none}';
  String get red => '${Ansi(true).red}${this}${Ansi(true).none}';
  String get gray => '${Ansi(true).gray}${this}${Ansi(true).none}';
}

extension StringListExtensions on List<String> {
  bool containsArgument(String arg) =>
      any((item) => item.toLowerCase().trim() == arg);
  bool containsArguments(List<String> args) =>
      any((item) => args.contains(item.toLowerCase().trim()));
}

extension StringConversions on String? {
  String? toHtmlEscape() =>
      this != null ? const HtmlEscape().convert(this!) : null;
}

extension FileSystemEntityExtensions on FileSystemEntity {
  Future<FileSystemEntity?> deleteIfExists({bool recursive = false}) async =>
      await exists() ? delete(recursive: recursive) : Future.value();
}

/// Copy directory content asynchronously
extension DirectoryExtensions on Directory {
  Future<void> copyDirectory(Directory destination) async {
    await for (FileSystemEntity entity in list(recursive: false)) {
      if (entity is Directory) {
        Directory newDirectory = Directory(
            path.join(destination.absolute.path, path.basename(entity.path)));
        await newDirectory.create();
        await entity.absolute.copyDirectory(newDirectory);
      } else if (entity is File) {
        await entity
            .copy(path.join(destination.path, path.basename(entity.path)));
      }
    }
  }
}

extension ProcessResultExtensions on ProcessResult {
  void exitOnError() {
    if (this.exitCode != 0) {
      GetIt.I<Logger>().stderr(this.stdout);
      throw this.stderr;
    }
  }
}

extension UniqueList<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}
