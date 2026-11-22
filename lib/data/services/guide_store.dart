import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Whether the first-launch question about the double-tap guide was
/// answered, in `guide.json` in the app's support folder: not the database,
/// so not the backup, and it goes with the app when deleted, so a fresh
/// install asks again.
class GuideStore {
  GuideStore({Future<File> Function()? file}) : _file = file ?? _defaultFile;

  final Future<File> Function() _file;

  static Future<File> _defaultFile() async =>
      File(p.join((await getApplicationSupportDirectory()).path, 'guide.json'));

  /// Not asked when the file is missing or broken.
  Future<bool> asked() async {
    try {
      return switch (jsonDecode(await (await _file()).readAsString())) {
        {'asked': true} => true,
        _ => false,
      };
    } on FileSystemException {
      return false;
    } on FormatException {
      return false;
    }
  }

  Future<void> markAsked() async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode({'asked': true}));
  }
}
