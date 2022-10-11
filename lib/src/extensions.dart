import 'dart:io';
import 'dart:convert' show HtmlEscape;
import 'package:cli_util/cli_logging.dart' show Ansi;
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
    await for (var entity in list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(
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
