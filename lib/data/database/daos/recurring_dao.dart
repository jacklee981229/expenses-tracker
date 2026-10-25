import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/note_utils.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/recurring_rules_table.dart';

part 'recurring_dao.g.dart';

const Uuid _uuid = Uuid();

class RecurringRuleWithCategory {
  const RecurringRuleWithCategory(this.rule, this.category);

  final RecurringRule rule;
  final ExpenseCategory category;
}

@DriftAccessor(tables: [RecurringRules, Categories])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  RecurringDao(super.attachedDatabase);

  /// Active rules first, then by day of month.
  Stream<List<RecurringRuleWithCategory>> watchAllWithCategory() {
    final query =
        select(recurringRules).join([
          innerJoin(
            categories,
            categories.id.equalsExp(recurringRules.categoryId),
          ),
        ])..orderBy([
          OrderingTerm.desc(recurringRules.isActive),
          OrderingTerm.asc(recurringRules.dayOfMonth),
          OrderingTerm.asc(recurringRules.createdAt),
        ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          RecurringRuleWithCategory(
            row.readTable(recurringRules),
            row.readTable(categories),
          ),
      ],
    );
  }

  Future<List<RecurringRule>> getAll() => select(recurringRules).get();

  Future<List<RecurringRule>> getActive() =>
      (select(recurringRules)..where((r) => r.isActive.equals(true))).get();

  Future<RecurringRule?> findById(String id) =>
      (select(recurringRules)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<String> insertRule({
    required int amountMinor,
    required String categoryId,
    required String? note,
    required int dayOfMonth,
    required String startMonth,
    required String? endMonth,
    required bool isActive,
    String? lastGeneratedMonth,
  }) async {
    final id = _uuid.v4();
    await into(recurringRules).insert(
      RecurringRulesCompanion.insert(
        id: id,
        amountMinor: amountMinor,
        categoryId: categoryId,
        note: Value(cleanNote(note)),
        dayOfMonth: dayOfMonth,
        startMonth: startMonth,
        endMonth: Value(endMonth),
        isActive: Value(isActive),
        lastGeneratedMonth: Value(lastGeneratedMonth),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return id;
  }

  /// Rewrites the rule. Expenses it already generated are not touched.
  Future<void> updateRule({
    required String id,
    required int amountMinor,
    required String categoryId,
    required String? note,
    required int dayOfMonth,
    required String startMonth,
    required String? endMonth,
    required bool isActive,
    Value<String?> lastGeneratedMonth = const Value.absent(),
  }) async {
    await (update(recurringRules)..where((r) => r.id.equals(id))).write(
      RecurringRulesCompanion(
        amountMinor: Value(amountMinor),
        categoryId: Value(categoryId),
        note: Value(cleanNote(note)),
        dayOfMonth: Value(dayOfMonth),
        startMonth: Value(startMonth),
        endMonth: Value(endMonth),
        isActive: Value(isActive),
        lastGeneratedMonth: lastGeneratedMonth,
      ),
    );
  }

  Future<void> setLastGeneratedMonth(String id, String monthKey) async {
    await (update(recurringRules)..where((r) => r.id.equals(id))).write(
      RecurringRulesCompanion(lastGeneratedMonth: Value(monthKey)),
    );
  }

  /// Generated expenses stay; the foreign key nulls their `recurringRuleId`.
  Future<void> deleteRule(String id) async {
    await (delete(recurringRules)..where((r) => r.id.equals(id))).go();
  }

  /// Backup import; see `CategoryDao.importRows`.
  Future<void> importRows(
    List<RecurringRule> rows, {
    required bool skipExisting,
  }) async {
    await batch(
      (batch) => batch.insertAll(
        recurringRules,
        rows,
        mode: skipExisting ? InsertMode.insertOrIgnore : InsertMode.insert,
      ),
    );
  }

  /// Backup import (replace).
  Future<void> deleteAll() async {
    await delete(recurringRules).go();
  }
}
