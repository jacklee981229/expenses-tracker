import 'date_utils.dart';
import 'money.dart';
import 'report.dart';

/// The report's figures as plain lines for Claude to comment on: only what
/// the report sheet already shows, nothing more from the database.
/// [period] is the sheet's period label (`November 2026`), [word] its
/// `week`, `month` or `year`.
String reportBrief(
  Report r, {
  required String period,
  required String word,
  required int daysSoFar,
}) {
  String change(int? percent) => switch (percent) {
    null => 'new',
    0 => 'same',
    > 0 => '$percent% more',
    _ => '${-percent}% less',
  };

  final lines = <String>[
    'Period: $period ($daysSoFar days so far)',
    'Spent: ${formatWithSymbol(r.totalMinor)}',
    if (r.compared)
      'Last $word: ${formatWithSymbol(r.totalBeforeMinor)} '
          '(${change(r.totalChange)} this $word)',
    'Per day: ${formatWithSymbol(r.perDayMinor)}'
        '${r.perDayChange == null ? '' : ' (${change(r.perDayChange)} than '
                  'last $word\'s ${formatWithSymbol(r.perDayBeforeMinor)})'}',
    'By category:',
    for (final c in r.categories)
      '- ${c.name}: ${formatWithSymbol(c.totalMinor)}, ${c.percent}%'
          '${r.compared ? ', ${change(c.change)} against last $word' : ''}',
    'Fixed monthly expenses: ${formatWithSymbol(r.fixedMinor)}; '
        'everyday spending: ${formatWithSymbol(r.everydayMinor)}',
    'Biggest day: '
        '${formatWeekdayDayMonth(parseLocalDate(r.biggestDay.localDate))}, '
        '${formatWithSymbol(r.biggestDay.totalMinor)}',
    'Biggest expense: ${formatWithSymbol(r.biggestExpense.amountMinor)} on '
        '${r.biggestExpense.categoryName}'
        '${_note(r.biggestExpense.note)}',
    'Expenses: ${r.count}; days with no spending: ${r.noSpendDays}',
    if (r.notes.isNotEmpty) 'Most often:',
    for (final n in r.notes)
      '- ${n.note}: ${n.count} times, ${formatWithSymbol(n.totalMinor)}',
  ];
  return lines.join('\n');
}

String _note(String? note) {
  final trimmed = note?.trim() ?? '';
  return trimmed.isEmpty ? '' : ' ($trimmed)';
}
