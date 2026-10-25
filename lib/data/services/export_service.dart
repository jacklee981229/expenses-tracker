import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_info.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money.dart';
import '../database/app_database.dart';

/// Builds export files. CSV is for spreadsheets; JSON is the full-fidelity
/// backup that Import reads back.
class ExportService {
  ExportService(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const String _csvHeader = 'date,category,amount,note';

  /// RFC 4180 line break.
  static const String _csvLineBreak = '\r\n';

  /// Lets Excel detect UTF-8, so notes in Chinese or Malay survive.
  static const String _byteOrderMark = '﻿';

  /// One row per expense, oldest first, amount as a plain decimal.
  Future<String> buildCsv() async {
    final rows = await _db.transactionDao.getAllWithCategoryChronological();
    final buffer = StringBuffer(_byteOrderMark)
      ..write(_csvHeader)
      ..write(_csvLineBreak);
    for (final row in rows) {
      buffer
        ..writeAll([
          csvField(row.expense.localDate),
          csvField(row.category.name),
          formatMinor(row.expense.amountMinor, grouping: false),
          csvField(row.expense.note ?? ''),
        ], ',')
        ..write(_csvLineBreak);
    }
    return buffer.toString();
  }

  /// Everything needed to restore the database exactly. The settings carry
  /// this file's own export time as `lastExportAt`, so data restored from it
  /// does not claim it was never backed up.
  Future<Map<String, Object?>> buildJson() async {
    final exportedAt = _clock().millisecondsSinceEpoch;
    return {
      'version': kBackupFormatVersion,
      'exportedAt': exportedAt,
      'settings': {
        ...(await _db.settingsDao.get()).toJson(),
        'lastExportAt': exportedAt,
      },
      'categories': [
        for (final category in await _db.categoryDao.getAll())
          category.toJson(),
      ],
      'recurringRules': [
        for (final rule in await _db.recurringDao.getAll()) rule.toJson(),
      ],
      'transactions': [
        for (final expense in await _db.transactionDao.getAll())
          expense.toJson(),
      ],
    };
  }

  Future<File> writeCsvFile() async => _write('csv', await buildCsv());

  Future<File> writeJsonFile() async => _write(
    'json',
    const JsonEncoder.withIndent('  ').convert(await buildJson()),
  );

  /// Writes to the temporary directory, named `expenses-YYYY-MM-DD.ext`.
  Future<File> _write(String extension, String contents) async {
    final directory = await getTemporaryDirectory();
    final name = 'expenses-${toLocalDateString(_clock())}.$extension';
    return File(
      p.join(directory.path, name),
    ).writeAsString(contents, flush: true);
  }
}

final RegExp _needsQuoting = RegExp('[",\r\n]');

/// RFC 4180: a field with a comma, quote or line break is quoted, and inner
/// quotes are doubled.
String csvField(String value) {
  if (!value.contains(_needsQuoting)) return value;
  return '"${value.replaceAll('"', '""')}"';
}
