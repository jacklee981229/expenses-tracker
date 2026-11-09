import 'dart:convert';

import 'package:intl/intl.dart';

import 'claude_receipt.dart';
import 'date_utils.dart';
import 'insights.dart';
import 'money.dart';
import 'report.dart';

/// What Claude is sent for a report: [text], and [fingerprint], which stays
/// the same while the expenses and the period before's totals do (a new day
/// alone leaves it as it was).
typedef ReportBrief = ({String text, String fingerprint});

/// The period's expenses as plain lines for Claude to read, every one of
/// them, so it can say what is behind the report's figures. [expenses] are
/// the period's (following the filter), [previous] the period before's
/// spending per category (null under All). [period] is the sheet's label
/// (`November 2026`), [word] the period's `week`, `month` or `year` (null
/// under All). [daysSoFar] of [periodDays] have passed; [running] says the
/// period is still going.
// shortcut: every expense goes, for any period; fine for the app's first
// years. Group older months into totals once All passes ~1,000 expenses.
ReportBrief reportBrief({
  required List<ReportExpense> expenses,
  required List<CategorySpend>? previous,
  required String period,
  required String? word,
  required int daysSoFar,
  required int periodDays,
  required bool running,
}) {
  final before = previous ?? const <CategorySpend>[];
  final totalBefore = before.fold(0, (sum, c) => sum + c.totalMinor);
  final compared = word != null && totalBefore > 0;
  final ordered = [...expenses.indexed]
    ..sort((a, b) {
      final byDate = a.$2.localDate.compareTo(b.$2.localDate);
      return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
    });

  final head = <String>[
    if (word == null)
      'Period: all time, from the first expense'
    else
      'Period: $period ($periodDays days), '
          '${running ? 'still running' : 'finished'}',
    if (word == null)
      'Compared with: nothing'
    else if (!compared)
      'Compared with: nothing (no spending last $word)'
    else if (running)
      'Compared with: last $word as a whole. This $word is still running, '
          'so its figures are so far only.'
    else
      'Compared with: last $word as a whole',
  ];
  final days = word == null
      ? 'Days so far: $daysSoFar'
      : 'Days so far: $daysSoFar of $periodDays';

  final body = <String>[
    '',
    'Expenses (date | weekday | category | amount | note, or - for none | '
        'fixed marks a fixed monthly expense):',
    for (final (_, e) in ordered)
      [
        e.localDate,
        _weekday.format(parseLocalDate(e.localDate)),
        e.categoryName,
        formatWithSymbol(e.amountMinor),
        if (tidyNote(e.note) case final note when note.isNotEmpty)
          note
        else
          '-',
        if (e.fixed) 'fixed',
      ].join(' | '),
    ..._repeated(ordered.map((entry) => entry.$2)),
    '',
    'Totals this period: ${_totals(_byCategory(expenses))}'
        '; all ${formatWithSymbol(_sum(expenses))} '
        '(${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'})',
    if (compared)
      'Totals last $word: ${_totals(before)}; '
          'all ${formatWithSymbol(totalBefore)}',
  ];

  final rest = [...head, ...body].join('\n');
  return (text: [...head, days, ...body].join('\n'), fingerprint: _fnv1a(rest));
}

final DateFormat _weekday = DateFormat('EEE');

/// The notes seen more than once, as the app counts them: case and spaces
/// ignored, the first spelling standing for the rest. Biggest total first.
/// Claude is given the counts because at low effort it miscounted a shop's
/// orders.
List<String> _repeated(Iterable<ReportExpense> ordered) {
  final groups =
      <String, ({String note, int count, int totalMinor, List<String> days})>{};
  for (final e in ordered) {
    final note = tidyNote(e.note);
    if (note.isEmpty) continue;
    final key = note.toLowerCase();
    final seen = groups[key];
    final day = formatWeekdayDayMonth(parseLocalDate(e.localDate));
    final days = seen?.days ?? <String>[];
    if (days.lastOrNull != day) days.add(day);
    groups[key] = (
      note: seen?.note ?? note,
      count: (seen?.count ?? 0) + 1,
      totalMinor: (seen?.totalMinor ?? 0) + e.amountMinor,
      days: days,
    );
  }
  final repeated = groups.values.where((g) => g.count > 1).toList()
    ..sort((a, b) {
      final byTotal = b.totalMinor.compareTo(a.totalMinor);
      if (byTotal != 0) return byTotal;
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.note.compareTo(b.note);
    });
  if (repeated.isEmpty) return const [];
  return [
    '',
    'Notes seen more than once (count, total, days):',
    for (final g in repeated)
      '- ${g.note}: ${g.count} times, ${formatWithSymbol(g.totalMinor)} '
          '(${g.days.join(', ')})',
  ];
}

List<CategorySpend> _byCategory(List<ReportExpense> expenses) {
  final totals = <String, CategorySpend>{};
  for (final e in expenses) {
    final seen = totals[e.categoryId];
    totals[e.categoryId] = (
      id: e.categoryId,
      name: e.categoryName,
      totalMinor: (seen?.totalMinor ?? 0) + e.amountMinor,
    );
  }
  return totals.values.toList();
}

/// `Rent RM880.00; Food RM116.30`, biggest first.
String _totals(List<CategorySpend> spends) {
  final spent = spends.where((c) => c.totalMinor > 0).toList()
    ..sort((a, b) {
      final byTotal = b.totalMinor.compareTo(a.totalMinor);
      return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
    });
  return spent
      .map((c) => '${c.name} ${formatWithSymbol(c.totalMinor)}')
      .join('; ');
}

int _sum(List<ReportExpense> expenses) =>
    expenses.fold(0, (sum, e) => sum + e.amountMinor);

/// 64-bit FNV-1a of [text]'s UTF-8, in hex: the saved takes keep this
/// instead of a whole year's brief. A collision would only show an old take.
String _fnv1a(String text) {
  var hash = 0xcbf29ce484222325;
  for (final byte in utf8.encode(text)) {
    hash = (hash ^ byte) * 0x100000001b3;
  }
  // An int is signed: each half on its own, so the hex never has a minus.
  String half(int bits) => bits.toRadixString(16).padLeft(8, '0');
  return half(hash >>> 32) + half(hash & 0xffffffff);
}

final RegExp _spaces = RegExp(r'\s+');

/// [note] trimmed, its runs of spaces and line breaks made one space.
String tidyNote(String? note) => (note ?? '').trim().replaceAll(_spaces, ' ');

/// One of Claude's points and the category it is mostly about (null for
/// none, or a name that is not one of the period's).
typedef TakePoint = ({String text, String? category});

/// Claude's take on a report: one headline, then its points.
typedef ClaudeTake = ({String headline, List<TakePoint> points});

/// The most points a take shows.
const int kTakePoints = 3;

/// Claude's word for a point about no one category.
const String kNoCategory = 'none';

/// The take in a Messages API reply [body]. Null when Claude declined, was
/// cut off, or sent anything off the schema: no headline, no points.
/// [categories] are the period's category names.
ClaudeTake? parseTake(Map<String, dynamic> body, Set<String> categories) {
  final text = replyText(body);
  if (text == null) return null;
  try {
    return takeFromJson(jsonDecode(text), categories: categories);
  } on FormatException {
    return null;
  }
}

/// A take read back from [json]; null for anything off the shape. A point's
/// category outside [categories] (when given) counts as none.
ClaudeTake? takeFromJson(Object? json, {Set<String>? categories}) {
  if (json is! Map<String, dynamic>) return null;
  final headline = json['headline'];
  final points = json['points'];
  if (headline is! String || headline.trim().isEmpty || points is! List) {
    return null;
  }
  final read = <TakePoint>[
    for (final point in points)
      if (point is Map<String, dynamic>)
        if (point['text'] case final String text when text.trim().isNotEmpty)
          (
            text: text.trim(),
            category: switch (point['category']) {
              kNoCategory => null,
              final String name
                  when categories == null || categories.contains(name) =>
                name,
              _ => null,
            },
          ),
  ];
  if (read.isEmpty) return null;
  return (headline: headline.trim(), points: read.take(kTakePoints).toList());
}

Map<String, Object?> takeToJson(ClaudeTake take) => {
  'headline': take.headline,
  'points': [
    for (final point in take.points)
      {'text': point.text, 'category': point.category ?? kNoCategory},
  ],
};

/// Ringgit amounts in Claude's words (`RM1,449.85`, `RM46`), not a comma
/// after one.
final RegExp _amount = RegExp(r'RM ?\d+(?:,\d{3})*(?:\.\d+)?');

/// [text] in pieces, each RM amount a piece of its own, so it can be bold.
List<({String text, bool amount})> splitAmounts(String text) {
  final pieces = <({String text, bool amount})>[];
  var at = 0;
  for (final match in _amount.allMatches(text)) {
    if (match.start > at) {
      pieces.add((text: text.substring(at, match.start), amount: false));
    }
    pieces.add((text: match[0]!, amount: true));
    at = match.end;
  }
  if (at < text.length) pieces.add((text: text.substring(at), amount: false));
  return pieces;
}
