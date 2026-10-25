import 'package:drift/drift.dart';

import 'categories_table.dart';

class RecurringRules extends Table {
  TextColumn get id => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().nullable()();

  /// 1–31. Clamped to the month's last day when generating.
  IntColumn get dayOfMonth => integer()();

  /// `YYYY-MM`.
  TextColumn get startMonth => text()();

  /// `YYYY-MM`, null = open-ended.
  TextColumn get endMonth => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// `YYYY-MM`. The sole idempotency guard for generation.
  TextColumn get lastGeneratedMonth => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
