import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_info.dart';
import 'daos/analysis_dao.dart';
import 'daos/category_dao.dart';
import 'daos/hidden_note_dao.dart';
import 'daos/learned_note_dao.dart';
import 'daos/recurring_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/categories_table.dart';
import 'tables/hidden_notes_table.dart';
import 'tables/learned_notes_table.dart';
import 'tables/recurring_rules_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    RecurringRules,
    AppSettings,
    HiddenNotes,
    LearnedNotes,
  ],
  daos: [
    CategoryDao,
    TransactionDao,
    RecurringDao,
    AnalysisDao,
    SettingsDao,
    HiddenNoteDao,
    LearnedNoteDao,
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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final statement in _indexes) {
        await customStatement(statement);
      }
    },
    onUpgrade: (m, from, to) async {
      // 2 added named kinds of receipt page; 5 drops them again.
      // 3: notes taken out of the history chips.
      if (from < 3) await m.createTable(hiddenNotes);
      // 4: the folded total card, remembered.
      if (from < 4) await m.addColumn(appSettings, appSettings.totalCardFolded);
      // 5: notes learned per shop and amount replace the kinds of page.
      if (from < 5) {
        await customStatement('DROP TABLE IF EXISTS receipt_kinds');
        await m.createTable(learnedNotes);
      }
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
