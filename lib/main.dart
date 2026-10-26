import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/data_providers.dart';
import 'data/database/app_database.dart';
import 'shared/scan_link.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(ScanLinkObserver());
  final database = AppDatabase.onDevice();
  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const ExpenseTrackerApp(),
    ),
  );
}
