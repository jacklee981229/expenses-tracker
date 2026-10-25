import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/note_utils.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

const Uuid _uuid = Uuid();

class ExpenseWithCategory {
  const ExpenseWithCategory(this.expense, this.category);

  final Expense expense;
  final ExpenseCategory category;
}

@DriftAccessor(tables: [Transactions, Categories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.attachedDatabase);

  /// Expenses with their category, newest first. [start] and [end] are
  /// inclusive local dates; leave both null for all time.
  Stream<List<ExpenseWithCategory>> watchWithCategory({
    String? start,
    String? end,
    String? categoryId,
  }) {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);
    final conditions = <Expression<bool>>[
      if (start != null && end != null)
        transactions.localDate.isBetweenValues(start, end),
      if (categoryId != null) transactions.categoryId.equals(categoryId),
    ];
    if (conditions.isNotEmpty) query.where(Expression.and(conditions));
    query.orderBy([
      OrderingTerm.desc(transactions.localDate),
      OrderingTerm.desc(transactions.occurredAt),
    ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          ExpenseWithCategory(
            row.readTable(transactions),
            row.readTable(categories),
          ),
      ],
    );
  }

  /// Sum of expenses between inclusive local dates.
  Stream<int> watchTotal({required String start, required String end}) {
    final sum = transactions.amountMinor.sum();
    final query = selectOnly(transactions)
      ..addColumns([sum])
      ..where(transactions.localDate.isBetweenValues(start, end));
    return query.watchSingle().map((row) => row.read(sum) ?? 0);
  }

  Stream<int> watchCount() {
    final count = transactions.id.count();
    return (selectOnly(
      transactions,
    )..addColumns([count])).watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Every expense, oldest first.
  Future<List<Expense>> getAll() =>
      (select(transactions)..orderBy([
            (t) => OrderingTerm.asc(t.localDate),
            (t) => OrderingTerm.asc(t.occurredAt),
          ]))
          .get();

  /// Every expense with its category, oldest first (for CSV export).
  Future<List<ExpenseWithCategory>> getAllWithCategoryChronological() async {
    final query =
        select(transactions).join([
          innerJoin(
            categories,
            categories.id.equalsExp(transactions.categoryId),
          ),
        ])..orderBy([
          OrderingTerm.asc(transactions.localDate),
          OrderingTerm.asc(transactions.occurredAt),
        ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        ExpenseWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        ),
    ];
  }

  /// Adds an expense and returns its id. `localDate` is derived from
  /// [occurredAt] in device local time.
  Future<String> insertExpense({
    required int amountMinor,
    required String categoryId,
    required DateTime occurredAt,
    String? note,
    String source = TransactionSource.manual,
    String? recurringRuleId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(transactions).insert(
      TransactionsCompanion.insert(
        id: id,
        amountMinor: amountMinor,
        categoryId: categoryId,
        occurredAt: occurredAt.millisecondsSinceEpoch,
        localDate: toLocalDateString(occurredAt),
        note: Value(cleanNote(note)),
        source: source,
        recurringRuleId: Value(recurringRuleId),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  Future<void> updateExpense({
    required String id,
    required int amountMinor,
    required String categoryId,
    required DateTime occurredAt,
    String? note,
  }) async {
    await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amountMinor: Value(amountMinor),
        categoryId: Value(categoryId),
        occurredAt: Value(occurredAt.millisecondsSinceEpoch),
        localDate: Value(toLocalDateString(occurredAt)),
        note: Value(cleanNote(note)),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteExpense(String id) async {
    await (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Backup import; see `CategoryDao.importRows`.
  Future<void> importRows(
    List<Expense> rows, {
    required bool skipExisting,
  }) async {
    await batch(
      (batch) => batch.insertAll(
        transactions,
        rows,
        mode: skipExisting ? InsertMode.insertOrIgnore : InsertMode.insert,
      ),
    );
  }

  /// Backup import (replace).
  Future<void> deleteAll() async {
    await delete(transactions).go();
  }

  /// Every distinct note used in [categoryId], most recently used first.
  /// Matching is exact and case-sensitive.
  Stream<List<String>> watchNoteHistory(String categoryId) {
    return customSelect(
      'SELECT note, MAX(occurred_at) AS last_used '
      'FROM transactions '
      'WHERE category_id = ? '
      "AND note IS NOT NULL AND TRIM(note) != '' "
      'GROUP BY note '
      'ORDER BY last_used DESC',
      variables: [Variable.withString(categoryId)],
      readsFrom: {transactions},
    ).watch().map((rows) => [for (final row in rows) row.read<String>('note')]);
  }
}
