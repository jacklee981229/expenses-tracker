import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_info.dart';
import 'daos/analysis_dao.dart';
import 'daos/category_dao.dart';
import 'daos/receipt_kind_dao.dart';
import 'daos/recurring_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/categories_table.dart';
import 'tables/receipt_kinds_table.dart';
import 'tables/recurring_rules_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Transactions, RecurringRules, AppSettings, ReceiptKinds],
  daos: [
    CategoryDao,
    TransactionDao,
    RecurringDao,
    AnalysisDao,
    SettingsDao,
    ReceiptKindDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-device database: [kDatabaseFileName] in the app documents
  /// directory, which iOS includes in device backups.
  factory AppDatabase.onDevice() {
    return AppDatabase(
      LazyDatabase(() async {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(p.join(directory.path, kDatabaseFileName));
        return NativeDatabase.createInBackground(file);
      }),
    );
  }

  /// Any schema change bumps this and adds a step to [migration].
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final statement in _indexes) {
        await customStatement(statement);
      }
    },
    onUpgrade: (m, from, to) async {
      // 2: named kinds of receipt page, for reading screenshots.
      if (from < 2) await m.createTable(receiptKinds);
    },
    beforeOpen: (details) async {
      // SQLite leaves foreign keys off unless enabled on every connection.
      await customStatement('PRAGMA foreign_keys = ON');
      await settingsDao.ensureRow();
      if (details.wasCreated) {
        await categoryDao.seedDefaultsIfEmpty();
      }
    },
  );
}

const List<String> _indexes = [
  'CREATE INDEX idx_tx_local_date ON transactions(local_date)',
  'CREATE INDEX idx_tx_category ON transactions(category_id)',
  'CREATE INDEX idx_tx_date_category ON transactions(local_date, category_id)',
  // Backs the history chip strip.
  'CREATE INDEX idx_tx_cat_occurred '
      'ON transactions(category_id, occurred_at DESC)',
];
