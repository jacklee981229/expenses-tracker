import 'dart:convert';
import 'dart:io';

import '../../core/constants/app_info.dart';
import '../database/app_database.dart';
import '../database/daos/split_dao.dart';

enum ImportMode {
  /// Insert rows whose id is not already present. A category whose name
  /// the phone already has joins the phone's one instead.
  merge,

  /// Wipe all tables, then insert everything.
  replace,
}

/// The file is not a backup: not gzip or text, not JSON, or not shaped like
/// one.
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
    required this.splits,
  });

  final AppSettingsData? settings;
  final List<ExpenseCategory> categories;
  final List<RecurringRule> recurringRules;
  final List<Expense> transactions;

  /// Groups and what is in them; none in a file made before groups.
  final SplitBackup splits;
}

class ImportService {
  ImportService(this._db);

  final AppDatabase _db;

  /// Parses and validates a backup file's [bytes] before anything is
  /// touched: a gzipped backup or an old plain-JSON one, told apart by the
  /// gzip header, not the file name. Throws
  /// [UnsupportedBackupVersionException] or [InvalidBackupException].
  BackupData parse(List<int> bytes) {
    final String text;
    try {
      text = utf8.decode(_isGzip(bytes) ? gzip.decode(bytes) : bytes);
    } on FormatException {
      throw const InvalidBackupException();
    }
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
        splits: _splits(decoded['splits']),
      );
    } on Object {
      // Missing fields or wrong types anywhere in the file.
      throw const InvalidBackupException();
    }
  }

  /// The optional `splits` key: absent in files made before groups.
  static SplitBackup _splits(Object? raw) {
    if (raw == null) return (groups: [], people: [], entries: [], shares: []);
    final json = raw as Map<String, dynamic>;
    return (
      groups: _rows(json['groups'], SplitGroup.fromJson),
      people: _rows(json['people'], SplitPerson.fromJson),
      entries: _rows(json['entries'], SplitEntry.fromJson),
      shares: _rows(json['shares'], SplitShare.fromJson),
    );
  }

  static bool _isGzip(List<int> bytes) =>
      bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;

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
      if (mode == ImportMode.replace) {
        await _db.splitDao.deleteAll();
        await _db.transactionDao.deleteAll();
        await _db.recurringDao.deleteAll();
        await _db.categoryDao.deleteAll();
        await _db.categoryDao.importRows(data.categories, skipExisting: false);
        await _db.recurringDao.importRows(
          data.recurringRules,
          skipExisting: false,
        );
        await _db.transactionDao.importRows(
          data.transactions,
          skipExisting: false,
        );
        await _db.splitDao.importRows(data.splits, skipExisting: false);
        final settings = data.settings;
        if (settings != null) await _db.settingsDao.replaceWith(settings);
        return;
      }

      final phoneIds = await _mergeCategories(data.categories);
      String onPhone(String id) => phoneIds[id] ?? id;
      await _db.recurringDao.importRows([
        for (final rule in data.recurringRules)
          rule.copyWith(categoryId: onPhone(rule.categoryId)),
      ], skipExisting: true);
      await _db.transactionDao.importRows([
        for (final expense in data.transactions)
          expense.copyWith(categoryId: onPhone(expense.categoryId)),
      ], skipExisting: true);
      await _mergeSplits(data.splits, onPhone);
    });
  }

  /// Adds the groups, people and entries the phone doesn't have, each
  /// entry with the phone's category. Shares come only with a new entry: an
  /// entry already here keeps its own, or its shares could stop adding up.
  Future<void> _mergeSplits(
    SplitBackup backup,
    String Function(String id) onPhone,
  ) async {
    final here = {for (final e in (await _db.splitDao.getAll()).entries) e.id};
    await _db.splitDao.importRows((
      groups: backup.groups,
      people: backup.people,
      entries: [
        for (final entry in backup.entries)
          if (!here.contains(entry.id))
            entry.copyWith(categoryId: onPhone(entry.categoryId)),
      ],
      shares: [
        for (final share in backup.shares)
          if (!here.contains(share.entryId)) share,
      ],
    ), skipExisting: true);
  }

  /// Every install seeds its default categories with new random ids, so
  /// matching by id alone doubled "Food" and the rest. Each backup category
  /// goes to the phone's one with its id, else with its name (an active one
  /// before an archived one, then the oldest); only the rest are added, at
  /// the end of the order. Returns backup id → phone id.
  Future<Map<String, String>> _mergeCategories(
    List<ExpenseCategory> backup,
  ) async {
    final onPhone = await _db.categoryDao.getAll();
    final byId = {for (final category in onPhone) category.id: category};
    final byName = <String, ExpenseCategory>{};
    for (final category in onPhone) {
      final key = _nameKey(category.name);
      final held = byName[key];
      if (held == null || _preferred(category, held)) byName[key] = category;
    }

    var nextOrder =
        onPhone.fold(-1, (max, c) => c.sortOrder > max ? c.sortOrder : max) + 1;
    final phoneIds = <String, String>{};
    final added = <ExpenseCategory>[];
    // In the backup's own order, so new ones keep their order after the
    // phone's.
    final ordered = [...backup]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (final category in ordered) {
      final match = byId[category.id] ?? byName[_nameKey(category.name)];
      if (match != null) {
        phoneIds[category.id] = match.id;
        continue;
      }
      final row = category.copyWith(sortOrder: nextOrder++);
      added.add(row);
      byId[row.id] = row;
      byName[_nameKey(row.name)] = row;
      phoneIds[row.id] = row.id;
    }
    await _db.categoryDao.importRows(added, skipExisting: false);
    return phoneIds;
  }

  static String _nameKey(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  /// Whether [a] is a better match for a name than [b].
  static bool _preferred(ExpenseCategory a, ExpenseCategory b) {
    if (a.isArchived != b.isArchived) return !a.isArchived;
    return a.createdAt < b.createdAt;
  }
}
