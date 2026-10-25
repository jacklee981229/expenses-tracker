import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'recurring_rules_table.dart';

abstract final class TransactionSource {
  static const String manual = 'manual';
  static const String recurring = 'recurring';
}

@DataClassName('Expense')
class Transactions extends Table {
  TextColumn get id => text()();

  /// Sen. Never a double.
  IntColumn get amountMinor => integer()();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();

  /// Epoch milliseconds.
  IntColumn get occurredAt => integer()();

  /// `YYYY-MM-DD` in device local time, written from [occurredAt] at insert.
  /// All period grouping uses this column, never [occurredAt].
  TextColumn get localDate => text()();
  TextColumn get note => text().nullable()();

  /// [TransactionSource.manual] or [TransactionSource.recurring].
  TextColumn get source => text()();
  TextColumn get recurringRuleId => text().nullable().references(
    RecurringRules,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
