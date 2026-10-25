import 'package:expense_tracker/core/utils/duplicate_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 25, 12);
  const key = (amountMinor: 850, categoryId: 'food', note: 'Nasi lemak');

  SavedExpense saved(ExpenseKey k, Duration ago) =>
      (key: k, savedAt: now.subtract(ago));

  group('looksLikeDuplicateOf', () {
    test('same amount, category and note a few minutes ago', () {
      expect(
        looksLikeDuplicateOf(key, [
          saved(key, const Duration(minutes: 3)),
        ], now),
        isTrue,
      );
    });

    test('exactly at the window edge still counts', () {
      expect(
        looksLikeDuplicateOf(key, [saved(key, kDuplicateWindow)], now),
        isTrue,
      );
    });

    test('older than the window does not count', () {
      expect(
        looksLikeDuplicateOf(key, [
          saved(key, kDuplicateWindow + const Duration(seconds: 1)),
        ], now),
        isFalse,
      );
    });

    test('a different amount, category or note does not count', () {
      const minutes = Duration(minutes: 1);
      expect(
        looksLikeDuplicateOf(key, [
          saved((
            amountMinor: 851,
            categoryId: 'food',
            note: 'Nasi lemak',
          ), minutes),
          saved((
            amountMinor: 850,
            categoryId: 'coffee',
            note: 'Nasi lemak',
          ), minutes),
          saved((
            amountMinor: 850,
            categoryId: 'food',
            note: 'Roti canai',
          ), minutes),
        ], now),
        isFalse,
      );
    });

    test('notes are compared after trimming; no note matches no note', () {
      const minutes = Duration(minutes: 1);
      expect(
        looksLikeDuplicateOf(
          (amountMinor: 850, categoryId: 'food', note: ' Nasi lemak '),
          [saved(key, minutes)],
          now,
        ),
        isTrue,
      );
      expect(
        looksLikeDuplicateOf(
          (amountMinor: 500, categoryId: 'food', note: '  '),
          [saved((amountMinor: 500, categoryId: 'food', note: null), minutes)],
          now,
        ),
        isTrue,
      );
    });

    test('notes are case-sensitive, like the history chips', () {
      expect(
        looksLikeDuplicateOf(
          (amountMinor: 850, categoryId: 'food', note: 'nasi lemak'),
          [saved(key, const Duration(minutes: 1))],
          now,
        ),
        isFalse,
      );
    });

    test('nothing saved means no duplicate', () {
      expect(looksLikeDuplicateOf(key, const [], now), isFalse);
    });
  });
}
