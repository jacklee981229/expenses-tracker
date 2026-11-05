import 'package:expense_tracker/core/utils/insights.dart';
import 'package:expense_tracker/core/utils/report.dart';
import 'package:flutter_test/flutter_test.dart';

ReportExpense spend(
  String category,
  int amountMinor,
  String localDate, {
  String? note,
  bool fixed = false,
}) => (
  categoryId: category.toLowerCase(),
  categoryName: category,
  amountMinor: amountMinor,
  localDate: localDate,
  note: note,
  fixed: fixed,
);

CategorySpend before(String name, int totalMinor) =>
    (id: name.toLowerCase(), name: name, totalMinor: totalMinor);

void main() {
  test('nothing spent: no report', () {
    expect(buildReport(current: const [], daysSoFar: 5), isNull);
    expect(
      buildReport(current: [spend('Food', 0, '2026-11-01')], daysSoFar: 5),
      isNull,
    );
  });

  test('totals, per day and changes against the period before', () {
    final report = buildReport(
      current: [
        spend('Food', 3000, '2026-11-03'),
        spend('Food', 1000, '2026-11-01'),
        spend('Transport', 2000, '2026-11-02'),
        spend('Health', 500, '2026-11-02'),
      ],
      previous: [before('Food', 5000), before('Transport', 2000)],
      daysSoFar: 5,
      previousDays: 31,
    )!;
    expect(report.totalMinor, 6500);
    expect(report.compared, isTrue);
    // 6500 against 7000.
    expect(report.totalChange, -7);
    // 6500 / 5 = 1300 a day; 7000 / 31 = 226 (225.8 rounded half up).
    expect(report.perDayMinor, 1300);
    expect(report.totalBeforeMinor, 7000);
    expect(report.perDayBeforeMinor, 226);
    expect(report.perDayChange, 475);
    expect(report.count, 4);
    expect(report.categories.map((c) => (c.name, c.percent, c.change)), [
      ('Food', 62, -20),
      ('Transport', 31, 0),
      // New this period: nothing before to compare with.
      ('Health', 8, null),
    ]);
  });

  test('without a period before, nothing is compared', () {
    for (final previous in [
      null,
      <CategorySpend>[],
      [before('Food', 0)],
    ]) {
      final report = buildReport(
        current: [spend('Food', 1000, '2026-11-01')],
        previous: previous,
        daysSoFar: 1,
        previousDays: 30,
      )!;
      expect(report.compared, isFalse);
      expect(report.totalChange, isNull);
      expect(report.perDayChange, isNull);
      expect(report.categories.single.change, isNull);
    }
  });

  test('fixed against everyday', () {
    final report = buildReport(
      current: [
        spend('Bills', 9500, '2026-11-01', fixed: true),
        spend('Food', 1200, '2026-11-01'),
        spend('Rent', 100000, '2026-11-05', fixed: true),
      ],
      daysSoFar: 10,
    )!;
    expect(report.fixedMinor, 109500);
    expect(report.everydayMinor, 1200);
  });

  test('biggest day and expense: the later one wins a tie', () {
    final report = buildReport(
      current: [
        spend('Food', 700, '2026-11-04', note: 'Dinner'),
        spend('Food', 300, '2026-11-04'),
        spend('Car', 700, '2026-11-02', note: 'Service'),
        spend('Food', 1000, '2026-11-01'),
      ],
      daysSoFar: 5,
    )!;
    expect(report.biggestDay, (localDate: '2026-11-04', totalMinor: 1000));
    expect(report.biggestExpense.amountMinor, 1000);

    final tie = buildReport(
      current: [
        spend('Food', 700, '2026-11-04', note: 'Dinner'),
        spend('Car', 700, '2026-11-02', note: 'Service'),
      ],
      daysSoFar: 5,
    )!;
    expect(tie.biggestExpense.note, 'Dinner');
    expect(tie.biggestDay.localDate, '2026-11-04');
  });

  test('days with no spending so far', () {
    final report = buildReport(
      current: [
        spend('Food', 100, '2026-11-03'),
        spend('Food', 100, '2026-11-03'),
        spend('Food', 100, '2026-11-01'),
      ],
      daysSoFar: 5,
    )!;
    expect(report.noSpendDays, 3);
    final everyDay = buildReport(
      current: [spend('Food', 100, '2026-11-01')],
      daysSoFar: 1,
    )!;
    expect(everyDay.noSpendDays, 0);
  });

  test('notes: repeated ones only, ignoring case and spaces, top three', () {
    final report = buildReport(
      current: [
        spend('Food', 1200, '2026-11-09', note: 'Mamak'),
        spend('Food', 1000, '2026-11-08', note: ' mamak '),
        spend('Food', 900, '2026-11-07', note: 'MAMAK'),
        spend('Transport', 1500, '2026-11-06', note: 'Grab  car'),
        spend('Transport', 900, '2026-11-05', note: 'grab car'),
        spend('Food', 500, '2026-11-04', note: 'Coffee'),
        spend('Food', 500, '2026-11-03', note: 'coffee'),
        spend('Food', 100, '2026-11-02', note: 'Kuih'),
        spend('Food', 100, '2026-11-02', note: 'kuih'),
        spend('Food', 800, '2026-11-01', note: 'Once only'),
        spend('Food', 800, '2026-11-01', note: '  '),
        spend('Food', 800, '2026-11-01'),
      ],
      daysSoFar: 9,
    )!;
    expect(report.notes, [
      (note: 'Mamak', count: 3, totalMinor: 3100),
      // Two each: the bigger total first, so Kuih drops out.
      (note: 'Grab car', count: 2, totalMinor: 2400),
      (note: 'Coffee', count: 2, totalMinor: 1000),
    ]);
  });

  test('changePercent', () {
    expect(changePercent(150, 100), 50);
    expect(changePercent(50, 100), -50);
    expect(changePercent(100, 100), 0);
    expect(changePercent(100, 0), isNull);
    expect(changePercent(0, 100), -100);
  });
}
