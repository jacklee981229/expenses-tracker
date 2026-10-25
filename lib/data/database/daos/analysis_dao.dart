import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'analysis_dao.g.dart';

class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.totalMinor,
    required this.count,
  });

  final ExpenseCategory category;
  final int totalMinor;
  final int count;
}

/// Cross-table aggregation for the analysis screen.
@DriftAccessor(tables: [Transactions, Categories])
class AnalysisDao extends DatabaseAccessor<AppDatabase>
    with _$AnalysisDaoMixin {
  AnalysisDao(super.attachedDatabase);

  late final Expression<int> _total = transactions.amountMinor.sum();
  late final Expression<int> _count = transactions.id.count();

  /// Spending per category between inclusive local dates (both null = all
  /// time), limited to [categoryIds] when that is not empty. Largest first.
  Stream<List<CategoryTotal>> watchCategoryTotals({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) => _query(start, end, categoryIds).watch().map(_toTotals);

  Future<List<CategoryTotal>> categoryTotals({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) async => _toTotals(await _query(start, end, categoryIds).get());

  /// Distinct days with at least one expense, for the daily expense
  /// (the period total divided by the days you actually spent).
  Stream<int> watchActiveDays({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) => _activeDays(start, end, categoryIds).watchSingle().map(_readDays);

  Future<int> activeDays({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) async => _readDays(await _activeDays(start, end, categoryIds).getSingle());

  late final Expression<int> _days = transactions.localDate.count(
    distinct: true,
  );

  JoinedSelectStatement<HasResultSet, dynamic> _activeDays(
    String? start,
    String? end,
    Set<String> categoryIds,
  ) {
    final query = selectOnly(transactions)..addColumns([_days]);
    final filter = _filter(start, end, categoryIds);
    if (filter != null) query.where(filter);
    return query;
  }

  int _readDays(TypedResult row) => row.read(_days) ?? 0;

  JoinedSelectStatement<HasResultSet, dynamic> _query(
    String? start,
    String? end,
    Set<String> categoryIds,
  ) {
    final query =
        select(categories).join([
            innerJoin(
              transactions,
              transactions.categoryId.equalsExp(categories.id),
              useColumns: false,
            ),
          ])
          ..addColumns([_total, _count])
          ..groupBy([categories.id])
          ..orderBy([
            OrderingTerm.desc(_total),
            OrderingTerm.asc(categories.sortOrder),
          ]);
    final filter = _filter(start, end, categoryIds);
    if (filter != null) query.where(filter);
    return query;
  }

  Expression<bool>? _filter(
    String? start,
    String? end,
    Set<String> categoryIds,
  ) {
    final conditions = <Expression<bool>>[
      if (start != null && end != null)
        transactions.localDate.isBetweenValues(start, end),
      if (categoryIds.isNotEmpty) transactions.categoryId.isIn(categoryIds),
    ];
    return conditions.isEmpty ? null : Expression.and(conditions);
  }

  List<CategoryTotal> _toTotals(List<TypedResult> rows) => [
    for (final row in rows)
      CategoryTotal(
        category: row.readTable(categories),
        totalMinor: row.read(_total) ?? 0,
        count: row.read(_count) ?? 0,
      ),
  ];
}
