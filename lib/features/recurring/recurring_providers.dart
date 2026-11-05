import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/recurring_dao.dart';
import '../../data/database/daos/transaction_dao.dart';
import '../../data/services/recurring_generator.dart';

final recurringRulesProvider = StreamProvider<List<RecurringRuleWithCategory>>(
  (ref) => ref.watch(recurringDaoProvider).watchAllWithCategory(),
);

final recurringActionsProvider = Provider<RecurringActions>(
  (ref) => RecurringActions(
    ref.watch(recurringDaoProvider),
    ref.watch(transactionDaoProvider),
    ref.watch(recurringGeneratorProvider),
  ),
);

class RecurringActions {
  const RecurringActions(this._dao, this._expenses, this._generator);

  final RecurringDao _dao;
  final TransactionDao _expenses;
  final RecurringGenerator _generator;

  /// Creates or updates a rule, then generates anything now due. Edits apply
  /// to future months only; switching a paused rule back on skips the months
  /// it was paused. A new rule made from [template] (Set as Fixed Expense)
  /// takes that expense as its own.
  Future<void> save({
    required RecurringRule? existing,
    Expense? template,
    required int amountMinor,
    required String categoryId,
    required String? note,
    required int dayOfMonth,
    required String startMonth,
    required String? endMonth,
    required bool isActive,
  }) async {
    if (existing == null) {
      await _dao.transaction(() async {
        final id = await _dao.insertRule(
          amountMinor: amountMinor,
          categoryId: categoryId,
          note: note,
          dayOfMonth: dayOfMonth,
          startMonth: startMonth,
          endMonth: endMonth,
          isActive: isActive,
        );
        if (template != null) await _expenses.markFixed(template.id, id);
      });
    } else {
      final resumed = !existing.isActive && isActive;
      await _dao.updateRule(
        id: existing.id,
        amountMinor: amountMinor,
        categoryId: categoryId,
        note: note,
        dayOfMonth: dayOfMonth,
        startMonth: startMonth,
        endMonth: endMonth,
        isActive: isActive,
        lastGeneratedMonth: resumed
            ? Value(
                RecurringGenerator.lastGeneratedOnResume(
                  existing.lastGeneratedMonth,
                  DateTime.now(),
                ),
              )
            : const Value.absent(),
      );
    }
    await _generator.catchUp();
  }

  /// Expenses the rule already generated stay; their link is cleared.
  Future<void> delete(String id) => _dao.deleteRule(id);
}
