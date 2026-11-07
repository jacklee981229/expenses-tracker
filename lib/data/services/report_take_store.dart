import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/report_brief.dart';

/// How many periods and filters keep their take.
const int kSavedTakes = 12;

/// Claude's takes on the latest [kSavedTakes] reports, one per period and
/// filter, in one small JSON file in the app's support folder, so a take
/// outlives the iPhone closing the app. Not in the backup: a take can be
/// asked for again.
class ReportTakeStore {
  ReportTakeStore({Future<File> Function()? file})
    : _file = file ?? _defaultFile;

  final Future<File> Function() _file;

  /// Saves one after another, so two replies never write over each other.
  Future<void> _writing = Future.value();

  static Future<File> _defaultFile() async => File(
    p.join((await getApplicationSupportDirectory()).path, 'report_takes.json'),
  );

  /// The take saved for [key] (the period and filter), if it was written on
  /// expenses with this [fingerprint].
  Future<ClaudeTake?> find(String key, String fingerprint) async {
    await _writing;
    for (final entry in await _read()) {
      if (entry['key'] == key && entry['fingerprint'] == fingerprint) {
        return takeFromJson(entry['take']);
      }
    }
    return null;
  }

  /// Keeps [take] as [key]'s, first in the file, dropping the oldest past
  /// [kSavedTakes].
  Future<void> save(String key, String fingerprint, ClaudeTake take) {
    final write = _writing.then((_) async {
      final entries = [
        {'key': key, 'fingerprint': fingerprint, 'take': takeToJson(take)},
        for (final entry in await _read())
          if (entry['key'] != key) entry,
      ];
      final file = await _file();
      await file.parent.create(recursive: true);
      // Written beside it, then moved over: a crash mid-write never leaves
      // half a file.
      final next = File('${file.path}.tmp');
      await next.writeAsString(jsonEncode(entries.take(kSavedTakes).toList()));
      await next.rename(file.path);
    });
    // A failed write must not stop the next one, or a find.
    _writing = write.then((_) {}, onError: (Object _) {});
    return write;
  }

  /// The saved entries, newest first; none when the file is missing or
  /// broken.
  Future<List<Map<String, dynamic>>> _read() async {
    try {
      final decoded = jsonDecode(await (await _file()).readAsString());
      if (decoded is! List) return const [];
      return decoded.whereType<Map<String, dynamic>>().toList();
    } on FileSystemException {
      return const [];
    } on FormatException {
      return const [];
    }
  }
}
