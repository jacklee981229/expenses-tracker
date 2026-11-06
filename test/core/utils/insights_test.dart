import 'package:expense_tracker/core/utils/insights.dart';
import 'package:flutter_test/flutter_test.dart';

CategorySpend spend(String name, int totalMinor) =>
    (id: name.toLowerCase(), name: name, totalMinor: totalMinor);

const day = (localDate: '2026-09-24', totalMinor: 7258);

/// Each sentence in short, so a whole loop reads in one line.
List<String> describe(List<Insight> loop) => [
  for (final insight in loop)
    switch (insight) {
      CategoryChange(:final name, :final percent, :final up) =>
        '$name ${up ? '+' : '-'}$percent%',
      NewCategory(:final name, :final totalMinor) => '$name new $totalMinor',
      SameAsBefore(:final name) => '$name same',
      CategoryShare(:final name, :final totalMinor, :final percent) =>
        '$name $totalMinor $percent%',
      Projection(:final totalMinor) => 'pace $totalMinor',
      BiggestDay(:final localDate, :final totalMinor) =>
        'day $localDate $totalMinor',
    },
];

void main() {
  test('nothing to say for a period without spending', () {
    expect(insightLoop(current: const [], biggestDay: day), isEmpty);
    expect(insightLoop(current: [spend('Food', 0)], biggestDay: day), isEmpty);
  });

  test('with nothing to compare: the biggest day, then shares', () {
    final loop = insightLoop(
      current: [spend('Groceries', 1740), spend('Food', 10018)],
      biggestDay: day,
    );
    expect(describe(loop), [
      'day 2026-09-24 7258',
      'Food 10018 85%',
      'Groceries 1740 15%',
    ]);
    final emptyBefore = insightLoop(
      current: [spend('Food', 500)],
      previous: const [],
      biggestDay: day,
    );
    expect(describe(emptyBefore), ['day 2026-09-24 7258', 'Food 500 100%']);
  });

  test('the most moved category first, the others after, the day last', () {
    final loop = insightLoop(
      current: [spend('Food', 4000), spend('Groceries', 500)],
      previous: [spend('Food', 6018), spend('Groceries', 1240)],
      biggestDay: day,
    );
    expect(describe(loop), [
      'Food -34%',
      'Groceries -60%',
      'day 2026-09-24 7258',
    ]);
  });

  test('a big drop leads a smaller rise', () {
    final loop = insightLoop(
      current: [spend('Food', 10500), spend('Transport', 2000)],
      previous: [spend('Food', 10000), spend('Transport', 5000)],
    );
    expect(describe(loop), ['Transport -60%', 'Food +5%']);
  });

  test('a category gone entirely leads at 100% less', () {
    final loop = insightLoop(
      current: [spend('Food', 1000)],
      previous: [spend('Food', 1000), spend('Shopping', 8000)],
      biggestDay: day,
    );
    expect(describe(loop), [
      'Shopping -100%',
      'Food same',
      'day 2026-09-24 7258',
    ]);
  });

  test('a category with no spending before is new', () {
    final loop = insightLoop(
      current: [spend('Food', 1000), spend('Travel', 4500)],
      previous: [spend('Food', 1000)],
    );
    expect(describe(loop), ['Travel new 4500', 'Food same']);
  });

  test('nothing moved: the biggest day leads, then each category', () {
    final loop = insightLoop(
      current: [spend('Food', 100400), spend('Rent', 150000)],
      previous: [spend('Food', 100000), spend('Rent', 150000)],
      biggestDay: day,
    );
    expect(describe(loop), ['day 2026-09-24 7258', 'Rent same', 'Food same']);
  });

  test('percentages round half up', () {
    final loop = insightLoop(
      current: [spend('Food', 1005)],
      previous: [spend('Food', 1000)],
    );
    expect(describe(loop), ['Food +1%']);
  });

  test('equal moves go to the bigger spender now, then by name', () {
    expect(
      describe(
        insightLoop(
          current: [spend('Food', 3000), spend('Transport', 6000)],
          previous: [spend('Food', 2000), spend('Transport', 5000)],
        ),
      ).first,
      'Transport +20%',
    );
    expect(
      describe(
        insightLoop(
          current: [spend('Petrol', 3000), spend('Food', 3000)],
          previous: [spend('Petrol', 2000), spend('Food', 2000)],
        ),
      ),
      ['Food +50%', 'Petrol +50%'],
    );
  });

  group('month-end projection', () {
    test('fixed expenses count once, everyday spending keeps its pace', () {
      // Rent RM880 fixed, RM120 everyday over 6 of 30 days.
      expect(
        projectMonth(
          totalMinor: 100000,
          fixedMinor: 88000,
          daysSoFar: 6,
          monthDays: 30,
        ),
        88000 + 60000,
      );
    });

    test('rounds half up to the sen', () {
      // RM10 over 3 of 31 days: 1000 * 31 / 3 = 10333.33 sen.
      expect(
        projectMonth(
          totalMinor: 1000,
          fixedMinor: 0,
          daysSoFar: 3,
          monthDays: 31,
        ),
        10333,
      );
    });

    test('says nothing too early, on the last day or with no spending', () {
      int? project(int total, int day) => projectMonth(
        totalMinor: total,
        fixedMinor: 0,
        daysSoFar: day,
        monthDays: 30,
      );
      expect(project(5000, kProjectionFromDay - 1), isNull);
      expect(project(5000, kProjectionFromDay), isNotNull);
      expect(project(5000, 30), isNull);
      expect(project(0, 10), isNull);
    });

    test('goes first in the summary', () {
      expect(
        describe(
          insightLoop(
            current: [spend('Food', 3000)],
            biggestDay: day,
            projectedMinor: 9000,
          ),
        ),
        ['pace 9000', 'day 2026-09-24 7258', 'Food 3000 100%'],
      );
    });
  });

  group('category change sticker', () {
    String label(int now, int was, {bool percent = false}) =>
        changeLabel(spendChange(now, was), percent: percent);

    test('judges up, down, new and the same as the summary line', () {
      expect(spendChange(15460, 18000), (
        kind: ChangeKind.down,
        deltaMinor: -2540,
        percent: -14,
      ));
      expect(spendChange(13500, 9000), (
        kind: ChangeKind.up,
        deltaMinor: 4500,
        percent: 50,
      ));
      expect(spendChange(32000, 0), (
        kind: ChangeKind.fresh,
        deltaMinor: 32000,
        percent: null,
      ));
      expect(spendChange(88000, 88000).kind, ChangeKind.same);
      // 0.4% rounds to nothing, as "same as last month" does.
      expect(spendChange(100400, 100000).kind, ChangeKind.same);
      expect(spendChange(100500, 100000).kind, ChangeKind.up);
    });

    test('shows ringgit without sen when whole', () {
      expect(label(13500, 9000), '\u{25B2}RM45');
      expect(label(15460, 18000), '\u{25BC}RM25.40');
      expect(label(32000, 0), 'New');
      expect(label(88000, 88000), '= RM0');
      expect(label(100350, 100000), '\u{2248} RM3.50');
    });

    test('shows whole percent', () {
      expect(label(13500, 9000, percent: true), '\u{25B2}50%');
      expect(label(15460, 18000, percent: true), '\u{25BC}14%');
      expect(label(32000, 0, percent: true), 'New');
      expect(label(100350, 100000, percent: true), '0%');
    });
  });
}
