import 'dart:math' as math;

import 'insights.dart';
import 'money.dart';

/// One expense of the period, as the report needs it.
typedef ReportExpense = ({
  String categoryId,
  String categoryName,
  int amountMinor,
  String localDate,
  String? note,
  bool fixed,
});

/// A category's line: its spending, share of the period in whole percent,
/// and [change] against the period before ([changePercent]).
typedef ReportCategory = ({
  String id,
  String name,
  int totalMinor,
  int percent,
  int? change,
});

/// A note seen more than once: how often, and what it came to.
typedef ReportNote = ({String note, int count, int totalMinor});

/// The Analysis report for one period, following the category filter.
class Report {
  const Report({
    required this.totalMinor,
    required this.compared,
    required this.totalChange,
    required this.totalBeforeMinor,
    required this.perDayMinor,
    required this.perDayBeforeMinor,
    required this.perDayChange,
    required this.categories,
    required this.fixedMinor,
    required this.biggestDay,
    required this.biggestExpense,
    required this.count,
    required this.noSpendDays,
    required this.notes,
  });

  final int totalMinor;

  /// Whether the period before had spending to compare with. When it did, a
  /// null change means new spending; when not, there is no change to show.
  final bool compared;
  final int? totalChange;

  /// The period before's total and per day, for "than last month's RM…".
  final int totalBeforeMinor;
  final int perDayMinor;
  final int perDayBeforeMinor;
  final int? perDayChange;

  /// Biggest first, then by name.
  final List<ReportCategory> categories;

  /// Spending made by fixed monthly expenses; the rest is everyday.
  final int fixedMinor;
  int get everydayMinor => totalMinor - fixedMinor;

  /// The later day wins a tie, as the summary line's biggest day.
  final ({String localDate, int totalMinor}) biggestDay;

  /// The later one wins a tie.
  final ReportExpense biggestExpense;
  final int count;

  /// Days so far with nothing spent (on the filtered categories).
  final int noSpendDays;

  /// At most [kReportNotes], most often first, then the bigger total.
  final List<ReportNote> notes;
}

/// How many notes the report lists.
const int kReportNotes = 3;

/// The report for [current], the period's expenses. [previous] is the period
/// before's spending per category (null for All); a period still running is
/// compared with the whole period before, as the summary line is.
/// [daysSoFar] is the period's calendar days up to today and [previousDays]
/// the period before's full length, the two per day figures' divisors.
/// [kindNames] are the named kinds of receipt page: notes from one kind
/// (`GrabFood - Kedai Ali`, `GrabFood - Kedai Abu`) count as one.
/// Null when nothing was spent.
Report? buildReport({
  required List<ReportExpense> current,
  List<CategorySpend>? previous,
  required int daysSoFar,
  int previousDays = 0,
  Iterable<String> kindNames = const [],
}) {
  final total = current.fold(0, (sum, e) => sum + e.amountMinor);
  if (total <= 0) return null;
  final before = previous ?? const <CategorySpend>[];
  final totalBefore = before.fold(0, (sum, c) => sum + c.totalMinor);
  final compared = totalBefore > 0;
  final perDay = averageMinor(total, daysSoFar);
  final perDayBefore = averageMinor(totalBefore, previousDays);

  final byCategory = <String, ({String name, int totalMinor})>{};
  final byDay = <String, int>{};
  final notes = <String, ({String note, int count, int totalMinor})>{};
  var fixed = 0;
  var biggest = current.first;
  for (final e in current) {
    final category = byCategory[e.categoryId];
    byCategory[e.categoryId] = (
      name: e.categoryName,
      totalMinor: (category?.totalMinor ?? 0) + e.amountMinor,
    );
    byDay[e.localDate] = (byDay[e.localDate] ?? 0) + e.amountMinor;
    if (e.fixed) fixed += e.amountMinor;
    if (e.amountMinor > biggest.amountMinor ||
        (e.amountMinor == biggest.amountMinor &&
            e.localDate.compareTo(biggest.localDate) > 0)) {
      biggest = e;
    }
    final note = _kindOf(_tidy(e.note), kindNames);
    if (note.isNotEmpty) {
      final key = note.toLowerCase();
      final seen = notes[key];
      notes[key] = (
        // The first spelling met stands for the rest.
        note: seen?.note ?? note,
        count: (seen?.count ?? 0) + 1,
        totalMinor: (seen?.totalMinor ?? 0) + e.amountMinor,
      );
    }
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
              percent: (value.totalMinor * 100 / total).round(),
              change: compared
                  ? changePercent(value.totalMinor, was[key] ?? 0)
                  : null,
            ),
      ]..sort((a, b) {
        final byTotal = b.totalMinor.compareTo(a.totalMinor);
        return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
      });

  var biggestDay = byDay.entries.first;
  for (final day in byDay.entries) {
    if (day.value > biggestDay.value ||
        (day.value == biggestDay.value &&
            day.key.compareTo(biggestDay.key) > 0)) {
      biggestDay = day;
    }
  }

  final repeated = notes.values.where((n) => n.count > 1).toList()
    ..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) return byCount;
      final byTotal = b.totalMinor.compareTo(a.totalMinor);
      return byTotal != 0 ? byTotal : a.note.compareTo(b.note);
    });

  return Report(
    totalMinor: total,
    compared: compared,
    totalChange: compared ? changePercent(total, totalBefore) : null,
    totalBeforeMinor: totalBefore,
    perDayMinor: perDay,
    perDayBeforeMinor: perDayBefore,
    perDayChange: compared && previousDays > 0
        ? changePercent(perDay, perDayBefore)
        : null,
    categories: categories,
    fixedMinor: fixed,
    biggestDay: (localDate: biggestDay.key, totalMinor: biggestDay.value),
    biggestExpense: biggest,
    count: current.length,
    // shortcut: a future-dated expense counts as a spending day so far, one
    // too few no-spend days; pass today in if that ever matters.
    noSpendDays: math.max(0, daysSoFar - byDay.length),
    notes: repeated.take(kReportNotes).toList(),
  );
}

final RegExp _spaces = RegExp(r'\s+');

String _tidy(String? note) => (note ?? '').trim().replaceAll(_spaces, ' ');

/// The kind [note] was read from (`GrabFood` for `GrabFood - Kedai Ali`),
/// or the note itself.
String _kindOf(String note, Iterable<String> kindNames) {
  final lower = note.toLowerCase();
  for (final name in kindNames) {
    final kind = _tidy(name);
    final key = kind.toLowerCase();
    if (key.isNotEmpty && (lower == key || lower.startsWith('$key - '))) {
      return kind;
    }
  }
  return note;
}
