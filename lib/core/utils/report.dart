import 'insights.dart';

/// One expense of the period, as the report and Claude's brief need it.
typedef ReportExpense = ({
  String categoryId,
  String categoryName,
  int amountMinor,
  String localDate,
  String? note,
  bool fixed,
});

/// A category's row: its spending and its change against the period
/// before (null when there is nothing to compare with).
typedef ReportCategory = ({
  String id,
  String name,
  int totalMinor,
  SpendChange? change,
});

/// The categories under the rows, as one: how many, what they came to, and
/// the ids of the biggest [kOthersGrid], biggest first, for their colours.
typedef ReportOthers = ({int count, int totalMinor, List<String> ids});

/// The short report for one period, following the category filter.
class Report {
  const Report({
    required this.totalMinor,
    required this.change,
    required this.totalBeforeMinor,
    required this.count,
    required this.rows,
    required this.others,
  });

  final int totalMinor;

  /// Against the whole period before; null under All or when the period
  /// before had no spending.
  final SpendChange? change;

  /// The period before's total, for `vs last month's RM…`.
  final int totalBeforeMinor;

  /// How many expenses, for `Claude is reading N expenses…`.
  final int count;

  /// The biggest [kReportRows] categories, biggest first, then by name; all
  /// four when there are exactly four.
  final List<ReportCategory> rows;

  /// The rest as one row; null when every category has a row of its own.
  final ReportOthers? others;
}

/// How many categories get a row of their own.
const int kReportRows = 3;

/// How many of the others' colours the others row shows.
const int kOthersGrid = 4;

/// The report for [current], the period's expenses. [previous] is the
/// period before's spending per category (null for All); a period still
/// running is compared with the whole period before, as the summary line
/// is. Null when nothing was spent.
Report? buildReport({
  required List<ReportExpense> current,
  List<CategorySpend>? previous,
}) {
  final total = current.fold(0, (sum, e) => sum + e.amountMinor);
  if (total <= 0) return null;
  final before = previous ?? const <CategorySpend>[];
  final totalBefore = before.fold(0, (sum, c) => sum + c.totalMinor);
  final compared = totalBefore > 0;

  final byCategory = <String, ({String name, int totalMinor})>{};
  for (final e in current) {
    final category = byCategory[e.categoryId];
    byCategory[e.categoryId] = (
      name: e.categoryName,
      totalMinor: (category?.totalMinor ?? 0) + e.amountMinor,
    );
  }

  final was = {for (final c in before) c.id: c.totalMinor};
  final categories =
      [
        for (final MapEntry(:key, :value) in byCategory.entries)
          if (value.totalMinor > 0)
            (
              id: key,
              name: value.name,
              totalMinor: value.totalMinor,
              change: compared
                  ? spendChange(value.totalMinor, was[key] ?? 0)
                  : null,
            ),
      ]..sort((a, b) {
        final byTotal = b.totalMinor.compareTo(a.totalMinor);
        return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
      });

  // "1 other" would take a row to name one category: it gets its own.
  final shown = categories.length == kReportRows + 1
      ? categories.length
      : kReportRows;
  final rest = categories.skip(shown).toList();

  return Report(
    totalMinor: total,
    change: compared ? spendChange(total, totalBefore) : null,
    totalBeforeMinor: totalBefore,
    count: current.length,
    rows: categories.take(shown).toList(),
    others: rest.isEmpty
        ? null
        : (
            count: rest.length,
            totalMinor: rest.fold(0, (sum, c) => sum + c.totalMinor),
            ids: [for (final c in rest.take(kOthersGrid)) c.id],
          ),
  );
}
