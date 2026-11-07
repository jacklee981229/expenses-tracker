import 'package:expense_tracker/core/utils/insights.dart';
import 'package:expense_tracker/core/utils/report.dart';
import 'package:flutter_test/flutter_test.dart';

ReportExpense spend(
  String category,
  int amountMinor, [
  String localDate = '2026-11-01',
]) => (
  categoryId: category.toLowerCase(),
  categoryName: category,
  amountMinor: amountMinor,
  localDate: localDate,
  note: null,
  fixed: false,
);

CategorySpend before(String name, int totalMinor) =>
    (id: name.toLowerCase(), name: name, totalMinor: totalMinor);

List<String> names(Report r) => [for (final c in r.rows) c.name];

void main() {
  test('nothing spent: no report', () {
    expect(buildReport(current: const []), isNull);
    expect(buildReport(current: [spend('Food', 0)]), isNull);
  });

  test('total, its change in ringgit, and last period total', () {
    final report = buildReport(
      current: [
        spend('Food', 3000, '2026-11-03'),
        spend('Food', 1000),
        spend('Transport', 2000, '2026-11-02'),
        spend('Health', 500, '2026-11-02'),
      ],
      previous: [before('Food', 5000), before('Transport', 2000)],
    )!;
    expect(report.totalMinor, 6500);
    expect(report.totalBeforeMinor, 7000);
    expect(report.count, 4);
    // 6500 against 7000: RM5 less, 7%.
    expect(report.change, (
      kind: ChangeKind.down,
      deltaMinor: -500,
      percent: -7,
    ));
    expect(report.rows.map((c) => (c.name, c.totalMinor, c.change)), [
      ('Food', 4000, (kind: ChangeKind.down, deltaMinor: -1000, percent: -20)),
      ('Transport', 2000, (kind: ChangeKind.same, deltaMinor: 0, percent: 0)),
      // Nothing before to compare with: new.
      ('Health', 500, (kind: ChangeKind.fresh, deltaMinor: 500, percent: null)),
    ]);
    expect(report.others, isNull);
  });

  test('nothing to compare: no changes anywhere', () {
    for (final previous in [
      null,
      <CategorySpend>[],
      [before('Food', 0)],
    ]) {
      final report = buildReport(
        current: [spend('Food', 1000)],
        previous: previous,
      )!;
      expect(report.change, isNull);
      expect(report.totalBeforeMinor, 0);
      expect(report.rows.single.change, isNull);
    }
  });

  test('five categories: the top three, then the other two as one', () {
    final report = buildReport(
      current: [
        spend('Rent', 88000),
        spend('Food', 11630),
        spend('Utilities', 16820),
        spend('Petrol', 6510),
        spend('Shopping', 4590),
      ],
    )!;
    expect(names(report), ['Rent', 'Utilities', 'Food']);
    expect(report.others!.count, 2);
    expect(report.others!.totalMinor, 11100);
    expect(report.others!.ids, ['petrol', 'shopping']);
  });

  test('exactly four categories: four rows, no "1 other"', () {
    final report = buildReport(
      current: [
        spend('Rent', 4000),
        spend('Food', 3000),
        spend('Petrol', 2000),
        spend('Health', 1000),
      ],
    )!;
    expect(names(report), ['Rent', 'Food', 'Petrol', 'Health']);
    expect(report.others, isNull);
  });

  test('the others grid shows the four biggest others', () {
    final report = buildReport(
      current: [
        for (final (index, name) in [
          'A',
          'B',
          'C',
          'D',
          'E',
          'F',
          'G',
          'H',
        ].indexed)
          spend(name, 10000 - index * 1000),
      ],
    )!;
    expect(names(report), ['A', 'B', 'C']);
    expect(report.others!.count, 5);
    expect(report.others!.totalMinor, 7000 + 6000 + 5000 + 4000 + 3000);
    expect(report.others!.ids, ['d', 'e', 'f', 'g']);
  });

  test('ties go by name, so the rows stay put', () {
    final report = buildReport(
      current: [
        spend('Petrol', 1000),
        spend('Food', 1000),
        spend('Books', 1000),
        spend('Rent', 1000),
        spend('Gifts', 1000),
      ],
    )!;
    expect(names(report), ['Books', 'Food', 'Gifts']);
    expect(report.others!.ids, ['petrol', 'rent']);
  });

  test('the filter: only the categories it lets through are counted', () {
    // The provider passes the filtered expenses and the period before's
    // filtered totals; the report never sees the rest.
    final report = buildReport(
      current: [spend('Food', 2500), spend('Food', 500, '2026-11-02')],
      previous: [before('Food', 2000)],
    )!;
    expect(report.totalMinor, 3000);
    expect(report.count, 2);
    expect(report.change!.deltaMinor, 1000);
    expect(names(report), ['Food']);
  });

  test('changePercent', () {
    expect(changePercent(150, 100), 50);
    expect(changePercent(50, 100), -50);
    expect(changePercent(100, 100), 0);
    expect(changePercent(100, 0), isNull);
    expect(changePercent(0, 100), -100);
  });
}
