import 'package:expense_tracker/core/utils/learned_notes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shopKey', () {
    test('ignores case and runs of spaces', () {
      expect(shopKey(' CHIN  CHIEH HUI '), 'chin chieh hui');
      expect(shopKey('Chin Chieh Hui'), shopKey('CHIN CHIEH HUI'));
    });
  });

  group('noteToLearn', () {
    String? learn({
      String? shop = 'CHIN CHIEH HUI',
      int? amountMinor = 1100,
      String filled = 'CHIN CHIEH HUI',
      required String saved,
    }) => noteToLearn(
      shop: shop,
      amountMinor: amountMinor,
      filled: filled,
      saved: saved,
    );

    test('a note Jack changed is learned', () {
      expect(learn(saved: 'Panmee'), 'Panmee');
      expect(learn(saved: ' Panmee '), 'Panmee');
      // He changed a learned note again: the new one wins.
      expect(learn(filled: 'Panmee', saved: 'Kopi ice'), 'Kopi ice');
    });

    test('a kept or emptied note is not', () {
      expect(learn(saved: 'CHIN CHIEH HUI'), isNull);
      expect(learn(filled: 'Panmee', saved: 'Panmee '), isNull);
      expect(learn(saved: '  '), isNull);
    });

    test('a reading without a shop or amount teaches nothing', () {
      expect(learn(shop: null, filled: '', saved: 'Panmee'), isNull);
      expect(learn(shop: ' ', filled: '', saved: 'Panmee'), isNull);
      expect(learn(amountMinor: null, saved: 'Panmee'), isNull);
    });
  });
}
