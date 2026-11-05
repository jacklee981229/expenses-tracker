import 'package:expense_tracker/core/utils/bar_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('barScale', () {
    test('nothing spent scales to 0', () {
      expect(barScale([]), 0);
      expect(barScale([0, 0, 0]), 0);
    });

    test('no cap needed: the biggest bar fills the height', () {
      expect(barScale([1000, 1500, 1800, 0, 0]), 1800);
    });

    test('odd count caps at twice the median', () {
      // Five days spent, median 4000.
      expect(barScale([3862, 3223, 17700, 4378, 4000, 0, 0]), 8000);
    });

    test('even count uses the mean of the middle two', () {
      // The week from the prototype: median (3862 + 4378) / 2 = 4120.
      expect(barScale([3862, 3223, 17700, 4378, 0, 0, 0]), 8240);
    });

    test('exactly twice the median is not capped', () {
      expect(barScale([1000, 1000, 2000]), 2000);
      expect(barScale([1000, 1000, 2001]), 2000);
    });

    test('fewer than three bars with spending never caps', () {
      expect(barScale([100, 0, 90000, 0]), 90000);
      expect(barScale([0, 0, 90000]), 90000);
    });

    test('zero days are left out of the median', () {
      // With zeros counted the median would be 0 and everything capped.
      expect(barScale([500, 0, 0, 0, 600, 0, 700]), 700);
    });
  });
}
