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

/// One day's spending: its `YYYY-MM-DD` and total.
typedef DaySpend = ({String localDate, int totalMinor});

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

  /// Spending per month (`YYYY-MM`) between inclusive local dates, limited
  /// to [categoryIds] when that is not empty. Months with nothing are absent.
  Stream<Map<String, int>> watchMonthTotals({
    required String start,
    required String end,
    Set<String> categoryIds = const {},
  }) => _monthTotals(start, end, categoryIds).watch().map(_toMonths);

  Future<Map<String, int>> monthTotals({
    required String start,
    required String end,
    Set<String> categoryIds = const {},
  }) async => _toMonths(await _monthTotals(start, end, categoryIds).get());

  late final Expression<String> _month = transactions.localDate.substr(1, 7);

  JoinedSelectStatement<HasResultSet, dynamic> _monthTotals(
    String start,
    String end,
    Set<String> categoryIds,
  ) {
    return selectOnly(transactions)
      ..addColumns([_month, _total])
      ..where(_filter(start, end, categoryIds)!)
      ..groupBy([_month]);
  }

  Map<String, int> _toMonths(List<TypedResult> rows) => {
    for (final row in rows) row.read(_month)!: row.read(_total) ?? 0,
  };

  /// The day with the most spending between inclusive local dates (both
  /// null = all time), limited to [categoryIds] when that is not empty; the
  /// later day wins a tie. Null when there is no spending.
  Stream<DaySpend?> watchBiggestDay({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) => _biggestDay(start, end, categoryIds).watchSingleOrNull().map(_toDay);

  Future<DaySpend?> biggestDay({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) async =>
      _toDay(await _biggestDay(start, end, categoryIds).getSingleOrNull());

  JoinedSelectStatement<HasResultSet, dynamic> _biggestDay(
    String? start,
    String? end,
    Set<String> categoryIds,
  ) {
    final query = selectOnly(transactions)
      ..addColumns([transactions.localDate, _total])
      ..groupBy([transactions.localDate])
      ..orderBy([
        OrderingTerm.desc(_total),
        OrderingTerm.desc(transactions.localDate),
      ])
      ..limit(1);
    final filter = _filter(start, end, categoryIds);
    if (filter != null) query.where(filter);
    return query;
  }

  DaySpend? _toDay(TypedResult? row) => row == null
      ? null
      : (
          localDate: row.read(transactions.localDate)!,
          totalMinor: row.read(_total) ?? 0,
        );

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
