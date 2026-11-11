import 'package:expense_tracker/core/utils/split_settle.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Entry = ({String payer, int amount, Map<String, int> shares});

_Entry _equal(int amount, String payer, List<String> sharers) => (
  payer: payer,
  amount: amount,
  shares: equalShares(amount: amount, payer: payer, sharers: sharers),
);

/// Applies [payments] to [balances] and returns what is left.
Map<String, int> _after(
  Map<String, int> balances,
  List<SplitPayment> payments,
) {
  final left = Map.of(balances);
  for (final p in payments) {
    left[p.from] = left[p.from]! + p.amount;
    left[p.to] = left[p.to]! - p.amount;
  }
  return left;
}

void main() {
  const people = ['me', 'ali', 'mei', 'raj'];

  group('equalShares', () {
    test('RM100 by 3: the payer takes the odd sen', () {
      expect(
        equalShares(amount: 10000, payer: 'ali', sharers: ['me', 'ali', 'mei']),
        {'me': 3333, 'ali': 3334, 'mei': 3333},
      );
    });

    test('a payer not sharing: the odd sen go in the group order', () {
      expect(
        equalShares(amount: 1000, payer: 'raj', sharers: ['me', 'ali', 'mei']),
        {'me': 334, 'ali': 333, 'mei': 333},
      );
      expect(
        equalShares(amount: 1001, payer: 'raj', sharers: ['me', 'ali', 'mei']),
        {'me': 334, 'ali': 334, 'mei': 333},
      );
    });

    test('shares always add up to the amount', () {
      for (var amount = 0; amount < 500; amount += 7) {
        for (var n = 1; n <= 4; n++) {
          final shares = equalShares(
            amount: amount,
            payer: 'mei',
            sharers: people.take(n).toList(),
          );
          expect(shares.values.fold(0, (a, b) => a + b), amount);
        }
      }
    });

    test('one sharer takes it all', () {
      expect(equalShares(amount: 4550, payer: 'me', sharers: ['ali']), {
        'ali': 4550,
      });
    });
  });

  group('splitBalances', () {
    test('paid minus share, adding up to zero', () {
      final balances = splitBalances(people, [
        _equal(12000, 'me', people), // 30 each
        _equal(6000, 'ali', ['ali', 'mei']), // 30 each
        _equal(1001, 'raj', ['me', 'ali', 'mei']), // payer not sharing
      ]);
      expect(balances, {
        'me': 12000 - 3000 - 334,
        'ali': 6000 - 3000 - 3000 - 334,
        'mei': -3000 - 3000 - 333,
        'raj': 1001 - 3000,
      });
      expect(balances.values.fold(0, (a, b) => a + b), 0);
    });

    test('someone in no entry is at zero', () {
      expect(
        splitBalances(people, [
          _equal(500, 'me', ['me']),
        ]),
        {'me': 0, 'ali': 0, 'mei': 0, 'raj': 0},
      );
    });
  });

  group('whoPaysWhom', () {
    test('settles everyone, at most people − 1 payments', () {
      final balances = splitBalances(people, [
        _equal(12000, 'me', people),
        _equal(6000, 'ali', ['ali', 'mei']),
        _equal(1001, 'raj', ['me', 'ali', 'mei']),
        _equal(8800, 'mei', people),
      ]);
      final payments = whoPaysWhom(people, balances);
      expect(payments.length, lessThanOrEqualTo(people.length - 1));
      expect(_after(balances, payments).values, everyElement(0));
      expect(payments.every((p) => p.amount > 0), isTrue);
    });

    test('biggest debtor pays biggest creditor first', () {
      final payments = whoPaysWhom(people, {
        'me': 5000,
        'ali': -3500,
        'mei': -1500,
        'raj': 0,
      });
      expect(payments, const [
        SplitPayment(from: 'ali', to: 'me', amount: 3500),
        SplitPayment(from: 'mei', to: 'me', amount: 1500),
      ]);
    });

    test('nobody at zero is listed', () {
      final payments = whoPaysWhom(people, {
        'me': 0,
        'ali': 200,
        'mei': -200,
        'raj': 0,
      });
      expect(payments, const [
        SplitPayment(from: 'mei', to: 'ali', amount: 200),
      ]);
    });

    test('ties go by the group order, the same every run', () {
      const balances = {'me': -100, 'ali': -100, 'mei': 100, 'raj': 100};
      const expected = [
        SplitPayment(from: 'me', to: 'mei', amount: 100),
        SplitPayment(from: 'ali', to: 'raj', amount: 100),
      ];
      expect(whoPaysWhom(people, balances), expected);
      expect(whoPaysWhom(people, Map.of(balances)), expected);
    });

    test('all settled gives no payments', () {
      expect(whoPaysWhom(people, {'me': 0, 'ali': 0}), isEmpty);
    });
  });
}
