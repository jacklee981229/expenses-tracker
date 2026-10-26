import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/daos/analysis_dao.dart';
import 'database/daos/category_dao.dart';
import 'database/daos/receipt_kind_dao.dart';
import 'database/daos/recurring_dao.dart';
import 'database/daos/settings_dao.dart';
import 'database/daos/transaction_dao.dart';
import 'services/export_service.dart';
import 'services/import_service.dart';
import 'services/receipt_reader.dart';
import 'services/recurring_generator.dart';

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

final receiptKindDaoProvider = Provider<ReceiptKindDao>(
  (ref) => ref.watch(appDatabaseProvider).receiptKindDao,
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

final receiptReaderProvider = Provider<ReceiptReader>((ref) => ReceiptReader());
