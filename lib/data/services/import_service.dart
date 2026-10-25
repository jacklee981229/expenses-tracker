import 'dart:convert';

import '../../core/constants/app_info.dart';
import '../database/app_database.dart';

enum ImportMode {
  /// Insert rows whose id is not already present.
  merge,

  /// Wipe all tables, then insert everything.
  replace,
}

/// The file is not JSON, or not shaped like a backup.
class InvalidBackupException implements Exception {
  const InvalidBackupException();
}

/// The backup's `version` is not one this app reads.
class UnsupportedBackupVersionException implements Exception {
  const UnsupportedBackupVersionException(this.version);

  final Object? version;
}

/// A parsed, validated backup file.
class BackupData {
  const BackupData({
    required this.settings,
    required this.categories,
    required this.recurringRules,
    required this.transactions,
  });

  final AppSettingsData? settings;
  final List<ExpenseCategory> categories;
  final List<RecurringRule> recurringRules;
  final List<Expense> transactions;
}

class ImportService {
  ImportService(this._db);

  final AppDatabase _db;

  /// Parses and validates a backup before anything is touched. Throws
  /// [UnsupportedBackupVersionException] or [InvalidBackupException].
  BackupData parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const InvalidBackupException();
    }
    if (decoded is! Map<String, dynamic>) throw const InvalidBackupException();
    final version = decoded['version'];
    if (version != kBackupFormatVersion) {
      throw UnsupportedBackupVersionException(version);
    }

    try {
      final settings = decoded['settings'];
      return BackupData(
        settings: settings == null
            ? null
            : AppSettingsData.fromJson(settings as Map<String, dynamic>),
        categories: _rows(decoded['categories'], ExpenseCategory.fromJson),
        recurringRules: _rows(
          decoded['recurringRules'],
          RecurringRule.fromJson,
        ),
        transactions: _rows(decoded['transactions'], Expense.fromJson),
      );
    } on Object {
      // Missing fields or wrong types anywhere in the file.
      throw const InvalidBackupException();
    }
  }

  static List<T> _rows<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson,
  ) => [
    for (final row in raw! as List<dynamic>)
      fromJson(row as Map<String, dynamic>),
  ];

  /// Applies [data] in one database transaction, so a failure anywhere (a
  /// clash, or an expense whose category is missing) changes nothing.
  Future<void> apply(BackupData data, ImportMode mode) {
    return _db.transaction(() async {
      final merge = mode == ImportMode.merge;
      if (!merge) {
        await _db.transactionDao.deleteAll();
        await _db.recurringDao.deleteAll();
        await _db.categoryDao.deleteAll();
      }
      await _db.categoryDao.importRows(data.categories, skipExisting: merge);
      await _db.recurringDao.importRows(
        data.recurringRules,
        skipExisting: merge,
      );
      await _db.transactionDao.importRows(
        data.transactions,
        skipExisting: merge,
      );
      final settings = data.settings;
      if (!merge && settings != null) {
        await _db.settingsDao.replaceWith(settings);
      }
    });
  }
}
