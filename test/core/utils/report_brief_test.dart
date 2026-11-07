import 'dart:convert';

import 'package:expense_tracker/core/utils/insights.dart';
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

CategorySpend before(String name, int totalMinor) =>
    (id: name.toLowerCase(), name: name, totalMinor: totalMinor);

final List<ReportExpense> november = [
  // Not in date order: the brief sorts them.
  spend('Food', 650, '2026-11-02', note: 'Nasi lemak'),
  spend('Rent', 88000, '2026-11-01', note: 'Rent', fixed: true),
  spend('Food', 480, '2026-11-02', note: 'Kopi Tiam 88'),
  spend('Food', 650, '2026-11-04', note: ' nasi  lemak '),
  spend('Petrol', 6510, '2026-11-03'),
  spend('Food', 2950, '2026-11-06', note: 'Food App - Kedai Ali'),
  spend('Food', 3060, '2026-11-06', note: 'food app - Kedai Abu'),
];

final List<CategorySpend> october = [
  before('Rent', 88000),
  before('Food', 50000),
  before('Travel', 33040),
];

ReportBrief brief({
  List<ReportExpense>? expenses,
  List<CategorySpend>? previous,
  int daysSoFar = 6,
  bool running = true,
}) => reportBrief(
  expenses: expenses ?? november,
  previous: previous ?? october,
  period: 'November 2026',
  word: 'month',
  daysSoFar: daysSoFar,
  periodDays: 30,
  running: running,
  kindNames: const ['Food App'],
);

Map<String, dynamic> reply(Object? take, {String stop = 'end_turn'}) => {
  'stop_reason': stop,
  'content': [
    {'type': 'thinking', 'thinking': ''},
    {'type': 'text', 'text': take is String ? take : jsonEncode(take)},
  ],
};

const Set<String> names = {'Food', 'Rent', 'Petrol'};

void main() {
  group('the brief', () {
    test('a running month: every expense, notes counted, both totals', () {
      expect(
        brief().text,
        'Period: November 2026 (30 days), still running\n'
        'Compared with: last month as a whole. This month is still running, '
        'so its figures are so far only.\n'
        'Days so far: 6 of 30\n'
        '\n'
        'Expenses (date | weekday | category | amount | note, or - for none '
        '| fixed marks a fixed monthly expense):\n'
        '2026-11-01 | Sun | Rent | RM880.00 | Rent | fixed\n'
        '2026-11-02 | Mon | Food | RM6.50 | Nasi lemak\n'
        '2026-11-02 | Mon | Food | RM4.80 | Kopi Tiam 88\n'
        '2026-11-03 | Tue | Petrol | RM65.10 | -\n'
        '2026-11-04 | Wed | Food | RM6.50 | nasi lemak\n'
        '2026-11-06 | Fri | Food | RM29.50 | Food App - Kedai Ali\n'
        '2026-11-06 | Fri | Food | RM30.60 | food app - Kedai Abu\n'
        '\n'
        'Notes seen more than once (count, total, days):\n'
        '- Food App: 2 times, RM60.10 (Fri 6 Nov)\n'
        '- Nasi lemak: 2 times, RM13.00 (Mon 2 Nov, Wed 4 Nov)\n'
        '\n'
        'Totals this period: Rent RM880.00; Food RM77.90; Petrol RM65.10; '
        'all RM1,023.00 (7 expenses)\n'
        'Totals last month: Rent RM880.00; Food RM500.00; Travel RM330.40; '
        'all RM1,710.40',
      );
    });

    test('a finished month is compared with last month as a whole', () {
      final text = brief(daysSoFar: 30, running: false).text;
      expect(
        text,
        startsWith(
          'Period: November 2026 (30 days), finished\n'
          'Compared with: last month as a whole\n'
          'Days so far: 30 of 30\n',
        ),
      );
    });

    test('nothing spent last month: nothing compared, no last totals', () {
      for (final previous in [
        <CategorySpend>[],
        [before('Food', 0)],
      ]) {
        final text = brief(previous: previous).text;
        expect(
          text,
          contains('Compared with: nothing (no spending last month)\n'),
        );
        expect(text, isNot(contains('Totals last month')));
      }
    });

    test('all time: nothing compared, days since the first expense', () {
      final text = reportBrief(
        expenses: [spend('Food', 1250, '2025-02-01', note: 'Mamak')],
        previous: null,
        period: 'All time',
        word: null,
        daysSoFar: 645,
        periodDays: 645,
        running: true,
      ).text;
      expect(
        text,
        startsWith(
          'Period: all time, from the first expense\n'
          'Compared with: nothing\n'
          'Days so far: 645\n',
        ),
      );
      expect(text, endsWith('all RM12.50 (1 expense)'));
      expect(text, isNot(contains('Notes seen')));
    });

    test('notes of one kind are one group, each kind its own', () {
      final text = reportBrief(
        expenses: [
          spend('Food', 2034, '2026-11-06', note: 'Food App - Kedai Ayam'),
          spend('Food', 1500, '2026-11-05', note: 'food app - Kedai Ali'),
          spend('Food', 1200, '2026-11-04', note: 'Food App'),
          spend('Food', 4000, '2026-11-03', note: 'Food Go - Kedai Abu'),
          spend('Food', 2000, '2026-11-02', note: 'Food go - Kedai Mala'),
          // Not a named kind: each note stands on its own.
          spend('Food', 900, '2026-11-01', note: 'Ride App - home'),
          spend('Food', 900, '2026-11-01', note: 'Ride App - office'),
        ],
        previous: null,
        period: 'November 2026',
        word: 'month',
        daysSoFar: 6,
        periodDays: 30,
        running: true,
        kindNames: const ['Food App', 'Food Go'],
      ).text;
      expect(
        text,
        contains(
          'Notes seen more than once (count, total, days):\n'
          '- Food Go: 2 times, RM60.00 (Mon 2 Nov, Tue 3 Nov)\n'
          '- Food App: 3 times, RM47.34 (Wed 4 Nov, Thu 5 Nov, Fri 6 Nov)\n'
          '\n',
        ),
      );
      expect(text, isNot(contains('- Ride App')));
    });

    test('a note seen once, or blank, is no group', () {
      final text = brief(
        expenses: [
          spend('Food', 100, '2026-11-01', note: 'Once only'),
          spend('Food', 100, '2026-11-01', note: '  '),
          spend('Food', 100, '2026-11-01'),
        ],
      ).text;
      expect(text, isNot(contains('Notes seen')));
      expect(text, contains('2026-11-01 | Sun | Food | RM1.00 | -\n'));
    });
  });

  group('the fingerprint', () {
    test('a new day alone keeps it', () {
      expect(brief(daysSoFar: 7).fingerprint, brief().fingerprint);
      expect(brief().fingerprint, matches(RegExp(r'^[0-9a-f]{16}$')));
    });

    test('any change to an expense or to last month changes it', () {
      final first = november.first;
      ReportExpense edited({
        int? amount,
        String? note,
        String? category,
        String? date,
        bool? fixed,
      }) => (
        categoryId: (category ?? first.categoryName).toLowerCase(),
        categoryName: category ?? first.categoryName,
        amountMinor: amount ?? first.amountMinor,
        localDate: date ?? first.localDate,
        note: note ?? first.note,
        fixed: fixed ?? first.fixed,
      );
      final changed = [
        edited(amount: 700),
        edited(note: 'Roti canai'),
        edited(category: 'Snacks'),
        edited(date: '2026-11-03'),
        edited(fixed: true),
      ];
      final prints = {
        brief().fingerprint,
        for (final e in changed)
          brief(expenses: [e, ...november.skip(1)]).fingerprint,
        brief(
          previous: [before('Rent', 88000), before('Food', 49000)],
        ).fingerprint,
        brief(expenses: november.skip(1).toList()).fingerprint,
      };
      expect(prints, hasLength(changed.length + 3));
    });
  });

  group("Claude's reply", () {
    const good = {
      'headline': 'Rent made up most of the month so far.',
      'points': [
        {'text': 'Nasi lemak four times came to RM26.00.', 'category': 'Food'},
        {'text': 'Petrol once, RM65.10.', 'category': 'Petrol'},
      ],
    };

    test('a good reply', () {
      final take = parseTake(reply(good), names)!;
      expect(take.headline, 'Rent made up most of the month so far.');
      expect(take.points, [
        (text: 'Nasi lemak four times came to RM26.00.', category: 'Food'),
        (text: 'Petrol once, RM65.10.', category: 'Petrol'),
      ]);
    });

    test('refused, cut off or not JSON: no answer', () {
      expect(parseTake(reply(good, stop: 'refusal'), names), isNull);
      expect(parseTake(reply(good, stop: 'max_tokens'), names), isNull);
      expect(
        parseTake(reply('{"headline": "Rent', stop: 'end_turn'), names),
        isNull,
      );
      expect(parseTake(reply('Rent led the month.'), names), isNull);
    });

    test('off the schema: no answer', () {
      for (final take in [
        <String, Object?>{},
        [good],
        {'headline': '  ', 'points': good['points']},
        {'headline': 'Rent led.', 'points': <Object>[]},
        {
          'headline': 'Rent led.',
          'points': [
            {'text': ' ', 'category': 'Food'},
            'Food',
          ],
        },
        {'headline': 7, 'points': good['points']},
      ]) {
        expect(parseTake(reply(take), names), isNull, reason: '$take');
      }
    });

    test("none, or a category that isn't the period's, has no category", () {
      final take = parseTake(
        reply({
          'headline': 'Rent led.',
          'points': [
            {'text': 'a', 'category': 'none'},
            {'text': 'b', 'category': 'Travel'},
            {'text': 'c'},
          ],
        }),
        names,
      )!;
      expect(take.points.map((p) => p.category), [null, null, null]);
    });

    test('four points: the first three; one point: as is', () {
      final four = parseTake(
        reply({
          'headline': 'Rent led.',
          'points': [
            for (final text in ['a', 'b', 'c', 'd'])
              {'text': text, 'category': 'Food'},
          ],
        }),
        names,
      )!;
      expect(four.points.map((p) => p.text), ['a', 'b', 'c']);
      final one = parseTake(
        reply({
          'headline': 'Rent led.',
          'points': [
            {'text': 'a', 'category': 'Food'},
          ],
        }),
        names,
      )!;
      expect(one.points, hasLength(1));
    });

    test('a saved take reads back as it was', () {
      final take = parseTake(
        reply({
          'headline': 'Rent led.',
          'points': [
            {'text': 'a', 'category': 'Food'},
            {'text': 'b', 'category': 'none'},
          ],
        }),
        names,
      )!;
      final again = takeFromJson(jsonDecode(jsonEncode(takeToJson(take))))!;
      expect(again.headline, take.headline);
      expect(again.points, take.points);
    });
  });

  test('amounts split out to be bold', () {
    expect(
      splitAmounts(
        'A RM238.00 hotel and two RM46.20 tolls, RM1,449.85 last month; '
        'RM46, then RM 5.',
      ),
      [
        (text: 'A ', amount: false),
        (text: 'RM238.00', amount: true),
        (text: ' hotel and two ', amount: false),
        (text: 'RM46.20', amount: true),
        (text: ' tolls, ', amount: false),
        (text: 'RM1,449.85', amount: true),
        (text: ' last month; ', amount: false),
        (text: 'RM46', amount: true),
        (text: ', then ', amount: false),
        (text: 'RM 5', amount: true),
        (text: '.', amount: false),
      ],
    );
    expect(splitAmounts('No money here.'), [
      (text: 'No money here.', amount: false),
    ]);
  });
}
