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
}
