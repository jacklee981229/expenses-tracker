import 'package:expense_tracker/core/utils/report.dart';
import 'package:expense_tracker/core/utils/report_brief.dart';
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

void main() {
  test('lists the figures the report shows, against last month', () {
    final report = buildReport(
      current: [
        spend('Food', 3000, '2026-11-03', note: 'Kedai Ali'),
        spend('Food', 1000, '2026-11-01', note: 'Kedai Ali'),
        spend('Transport', 2000, '2026-11-02'),
        spend('Rent', 50000, '2026-11-01', fixed: true),
      ],
      previous: [
        (id: 'food', name: 'Food', totalMinor: 5000),
        (id: 'rent', name: 'Rent', totalMinor: 50000),
      ],
      daysSoFar: 6,
      previousDays: 31,
    )!;

    expect(
      reportBrief(report, period: 'November 2026', word: 'month', daysSoFar: 6),
      'Period: November 2026 (6 days so far)\n'
      'Spent: RM560.00\n'
      'Last month: RM550.00 (2% more this month)\n'
      "Per day: RM93.33 (426% more than last month's RM17.74)\n"
      'By category:\n'
      '- Rent: RM500.00, 89%, same against last month\n'
      '- Food: RM40.00, 7%, 20% less against last month\n'
      '- Transport: RM20.00, 4%, new against last month\n'
      'Fixed monthly expenses: RM500.00; everyday spending: RM60.00\n'
      'Biggest day: Sun 1 Nov, RM510.00\n'
      'Biggest expense: RM500.00 on Rent\n'
      'Expenses: 4; days with no spending: 3\n'
      'Most often:\n'
      '- Kedai Ali: 2 times, RM40.00',
    );
  });

  test('with nothing to compare: no last-period lines, note shown', () {
    final report = buildReport(
      current: [spend('Food', 1250, '2026-11-02', note: ' Nasi lemak ')],
      daysSoFar: 2,
    )!;
    final brief = reportBrief(
      report,
      period: 'November 2026',
      word: 'month',
      daysSoFar: 2,
    );
    expect(brief, isNot(contains('Last month')));
    expect(brief, isNot(contains('against')));
    expect(brief, contains('Per day: RM6.25\n'));
    expect(brief, contains('Biggest expense: RM12.50 on Food (Nasi lemak)'));
    expect(brief, isNot(contains('Most often')));
  });
}
