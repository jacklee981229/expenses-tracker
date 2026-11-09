import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/daos/analysis_dao.dart';
import 'database/daos/category_dao.dart';
import 'database/daos/hidden_note_dao.dart';
import 'database/daos/learned_note_dao.dart';
import 'database/daos/recurring_dao.dart';
import 'database/daos/settings_dao.dart';
import 'database/daos/transaction_dao.dart';
import 'services/claude_api.dart';
import 'services/claude_key_store.dart';
import 'services/cloud_backup.dart';
import 'services/cloud_backup_api.dart';
import 'services/cloud_backup_store.dart';
import 'services/export_service.dart';
import 'services/import_service.dart';
import 'services/receipt_reader.dart';
import 'services/recurring_generator.dart';
import 'services/report_take_store.dart';

/// Overridden in `main()` with the on-device database, and in tests with an
/// in-memory one.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override appDatabaseProvider in main()'),
);

final categoryDaoProvider = Provider<CategoryDao>(
  (ref) => ref.watch(appDatabaseProvider).categoryDao,
);

final transactionDaoProvider = Provider<TransactionDao>(
  (ref) => ref.watch(appDatabaseProvider).transactionDao,
);

final recurringDaoProvider = Provider<RecurringDao>(
  (ref) => ref.watch(appDatabaseProvider).recurringDao,
);

final analysisDaoProvider = Provider<AnalysisDao>(
  (ref) => ref.watch(appDatabaseProvider).analysisDao,
);

final settingsDaoProvider = Provider<SettingsDao>(
  (ref) => ref.watch(appDatabaseProvider).settingsDao,
);

final learnedNoteDaoProvider = Provider<LearnedNoteDao>(
  (ref) => ref.watch(appDatabaseProvider).learnedNoteDao,
);

final hiddenNoteDaoProvider = Provider<HiddenNoteDao>(
  (ref) => ref.watch(appDatabaseProvider).hiddenNoteDao,
);

final recurringGeneratorProvider = Provider<RecurringGenerator>(
  (ref) => RecurringGenerator(ref.watch(appDatabaseProvider)),
);

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(ref.watch(appDatabaseProvider)),
);

final importServiceProvider = Provider<ImportService>(
  (ref) => ImportService(ref.watch(appDatabaseProvider)),
);

final claudeApiProvider = Provider<ClaudeApi>((ref) => ClaudeApi());

final reportTakeStoreProvider = Provider<ReportTakeStore>(
  (ref) => ReportTakeStore(),
);

final claudeKeyStoreProvider = Provider<ClaudeKeyStore>(
  (ref) => const ClaudeKeyStore(),
);

/// The Claude API key, or null when none is set. Invalidate after a change.
final claudeKeyProvider = FutureProvider<String?>(
  (ref) => ref.watch(claudeKeyStoreProvider).read(),
);

final cloudBackupProvider = Provider<CloudBackup>(
  (ref) => CloudBackup(
    api: CloudBackupApi(),
    tokens: const CloudBackupTokenStore(),
    states: CloudBackupStateStore(),
    exporter: ref.watch(exportServiceProvider),
    importer: ref.watch(importServiceProvider),
    settings: ref.watch(settingsDaoProvider),
    transactions: ref.watch(transactionDaoProvider),
  ),
);

/// Cloud backup on this phone, for Settings. Invalidate after a change or
/// an upload.
final cloudBackupStatusProvider = FutureProvider<CloudBackupStatus>(
  (ref) => ref.watch(cloudBackupProvider).status(),
);

final receiptReaderProvider = Provider<ReceiptReader>(
  (ref) => ReceiptReader(
    claude: ref.watch(claudeApiProvider),
    keys: ref.watch(claudeKeyStoreProvider),
  ),
);
