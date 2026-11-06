import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';
import 'transaction_dao.dart' show ExpenseWithCategory;

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

  /// The earliest expense's `YYYY-MM-DD`, where All's daily expense starts
  /// counting days; null with no expenses.
  Stream<String?> watchFirstDate() =>
      _firstDate().watchSingle().map(_readFirst);

  Future<String?> firstDate() async =>
      _readFirst(await _firstDate().getSingle());

  late final Expression<String> _first = transactions.localDate.min();

  JoinedSelectStatement<HasResultSet, dynamic> _firstDate() =>
      selectOnly(transactions)..addColumns([_first]);

  String? _readFirst(TypedResult row) => row.read(_first);

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

  /// Spending per week between inclusive local dates, keyed by the
  /// `YYYY-MM-DD` its week starts on ([firstDayOfWeek] is an ISO weekday,
  /// 1 = Monday), limited to [categoryIds] when that is not empty. Weeks
  /// with nothing are absent.
  Stream<Map<String, int>> watchWeekTotals({
    required String start,
    required String end,
    required int firstDayOfWeek,
    Set<String> categoryIds = const {},
  }) {
    final week = _weekStart(firstDayOfWeek);
    return _weekTotals(
      week,
      start,
      end,
      categoryIds,
    ).watch().map((rows) => _toWeeks(week, rows));
  }

  Future<Map<String, int>> weekTotals({
    required String start,
    required String end,
    required int firstDayOfWeek,
    Set<String> categoryIds = const {},
  }) async {
    final week = _weekStart(firstDayOfWeek);
    return _toWeeks(
      week,
      await _weekTotals(week, start, end, categoryIds).get(),
    );
  }

  /// The date of the first day of `local_date`'s week. SQLite's `%w` counts
  /// from Sunday = 0, as does an ISO weekday mod 7.
  Expression<String> _weekStart(int firstDayOfWeek) {
    assert(firstDayOfWeek >= 1 && firstDayOfWeek <= 7);
    final back = 7 - firstDayOfWeek % 7;
    return CustomExpression<String>(
      "date(local_date, '-' || ((CAST(strftime('%w', local_date) AS INTEGER)"
      " + $back) % 7) || ' days')",
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _weekTotals(
    Expression<String> week,
    String start,
    String end,
    Set<String> categoryIds,
  ) {
    return selectOnly(transactions)
      ..addColumns([week, _total])
      ..where(_filter(start, end, categoryIds)!)
      ..groupBy([week]);
  }

  Map<String, int> _toWeeks(Expression<String> week, List<TypedResult> rows) =>
      {for (final row in rows) row.read(week)!: row.read(_total) ?? 0};

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

  /// What fixed monthly expenses came to between inclusive local dates,
  /// limited to [categoryIds] when that is not empty.
  Stream<int> watchFixedTotal({
    required String start,
    required String end,
    Set<String> categoryIds = const {},
  }) {
    final query = selectOnly(transactions)
      ..addColumns([_total])
      ..where(
        transactions.source.equals(TransactionSource.recurring) &
            _filter(start, end, categoryIds)!,
      );
    return query.watchSingle().map((row) => row.read(_total) ?? 0);
  }

  /// Every expense with its category between inclusive local dates (both
  /// null = all time), limited to [categoryIds] when that is not empty;
  /// newest first. The report's figures are worked out from these.
  Stream<List<ExpenseWithCategory>> watchExpenses({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) => _expenses(start, end, categoryIds).watch().map(_toExpenses);

  Future<List<ExpenseWithCategory>> expenses({
    String? start,
    String? end,
    Set<String> categoryIds = const {},
  }) async => _toExpenses(await _expenses(start, end, categoryIds).get());

  JoinedSelectStatement<HasResultSet, dynamic> _expenses(
    String? start,
    String? end,
    Set<String> categoryIds,
  ) {
    final query =
        select(transactions).join([
          innerJoin(
            categories,
            categories.id.equalsExp(transactions.categoryId),
          ),
        ])..orderBy([
          OrderingTerm.desc(transactions.localDate),
          OrderingTerm.desc(transactions.occurredAt),
        ]);
    final filter = _filter(start, end, categoryIds);
    if (filter != null) query.where(filter);
    return query;
  }

  List<ExpenseWithCategory> _toExpenses(List<TypedResult> rows) => [
    for (final row in rows)
      ExpenseWithCategory(
        row.readTable(transactions),
        row.readTable(categories),
      ),
  ];

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
