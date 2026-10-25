import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/data_providers.dart';
import 'data/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.onDevice();
  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const ExpenseTrackerApp(),
    ),
  );
}
