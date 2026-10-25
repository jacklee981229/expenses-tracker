import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseToMinor', () {
    test('parses whole and decimal amounts', () {
      expect(parseToMinor('12.5'), 1250);
      expect(parseToMinor('12.50'), 1250);
      expect(parseToMinor('12'), 1200);
      expect(parseToMinor('0'), 0);
      expect(parseToMinor('0.01'), 1);
      expect(parseToMinor('.5'), 50);
      expect(parseToMinor('5.'), 500);
    });

    test('accepts thousands separators and surrounding spaces', () {
      expect(parseToMinor('1,234.56'), 123456);
      expect(parseToMinor(' 7.20 '), 720);
    });

    test('rounds past two decimal places half up', () {
      expect(parseToMinor('12.345'), 1235);
      expect(parseToMinor('12.344'), 1234);
      expect(parseToMinor('0.005'), 1);
      expect(parseToMinor('0.0049'), 0);
      expect(parseToMinor('9.995'), 1000);
      expect(parseToMinor('99.999'), 10000);
    });

    test('rejects input that is not a non-negative amount', () {
      for (final input in ['', ' ', '.', 'abc', '-5', '1.2.3', '1e3', 'RM 5']) {
        expect(() => parseToMinor(input), throwsFormatException, reason: input);
      }
    });

    test('keeps large amounts exact', () {
      expect(parseToMinor('999999999.99'), 99999999999);
    });
  });

  group('formatMinor', () {
    test('always shows two decimals', () {
      expect(formatMinor(0), '0.00');
      expect(formatMinor(5), '0.05');
      expect(formatMinor(100), '1.00');
      expect(formatMinor(1250), '12.50');
    });

    test('groups thousands', () {
      expect(formatMinor(123456), '1,234.56');
      expect(formatMinor(100000000), '1,000,000.00');
    });

    test('can leave out thousands separators', () {
      expect(formatMinor(123456, grouping: false), '1234.56');
    });

    test('round-trips through parseToMinor', () {
      for (final minor in [0, 1, 99, 100, 1250, 123456, 99999999999]) {
        expect(parseToMinor(formatMinor(minor)), minor);
        expect(parseToMinor(formatMinor(minor, grouping: false)), minor);
      }
    });
  });

  test('formatWithSymbol prefixes RM with no space', () {
    expect(formatWithSymbol(1250), 'RM12.50');
    expect(formatWithSymbol(123456), 'RM1,234.56');
  });

  group('evaluateAmountExpression', () {
    test('adds and subtracts in sen', () {
      expect(evaluateAmountExpression('12.50+3'), 1550);
      expect(evaluateAmountExpression('10-2.5'), 750);
      expect(evaluateAmountExpression('1+2+3'), 600);
      expect(evaluateAmountExpression('0.1+0.2'), 30);
    });

    test('treats a single operand as the amount', () {
      expect(evaluateAmountExpression('12.5'), 1250);
      expect(evaluateAmountExpression('0.'), 0);
    });

    test('ignores a trailing operator', () {
      expect(evaluateAmountExpression('12.5+'), 1250);
      expect(evaluateAmountExpression('12.5-'), 1250);
    });

    test('can go negative, for the caller to reject', () {
      expect(evaluateAmountExpression('5-10'), -500);
    });

    test('rejects empty or malformed expressions', () {
      for (final input in ['', '+', '1++2', '1..2', '1+.']) {
        expect(evaluateAmountExpression(input), isNull, reason: input);
      }
    });
  });

  test('formatExpense shows a minus and RM', () {
    expect(formatExpense(1250), '-RM12.50');
    expect(formatExpense(123456), '-RM1,234.56');
  });

  group('formatShare', () {
    test('shows two decimals by default, rounded half up', () {
      expect(formatShare(4294, 10000), '42.94%');
      expect(formatShare(1, 3), '33.33%');
      expect(formatShare(2, 3), '66.67%');
      expect(formatShare(124, 1000), '12.40%');
      expect(formatShare(1000, 1000), '100.00%');
      expect(formatShare(0, 1000), '0.00%');
    });

    test('can use one decimal or none', () {
      expect(formatShare(124, 1000, decimals: 1), '12.4%');
      expect(formatShare(2, 3, decimals: 1), '66.7%');
      expect(formatShare(2, 3, decimals: 0), '67%');
    });

    test('is zero when there is no total', () {
      expect(formatShare(0, 0), '0.00%');
      expect(formatShare(5, 0, decimals: 1), '0.0%');
    });

    test('can drop trailing zeros, as the donut labels do', () {
      expect(formatShare(4294, 10000, trimZeros: true), '42.94%');
      expect(formatShare(2750, 10000, trimZeros: true), '27.5%');
      expect(formatShare(3000, 10000, trimZeros: true), '30%');
      expect(formatShare(1000, 1000, trimZeros: true), '100%');
      expect(formatShare(0, 0, trimZeros: true), '0%');
    });
  });

  group('averageMinor', () {
    test('divides in sen, rounding half up', () {
      expect(averageMinor(186300, 4), 46575);
      expect(averageMinor(100, 3), 33);
      expect(averageMinor(200, 3), 67);
      expect(averageMinor(5, 2), 3);
    });

    test('is zero when there is nothing to divide by', () {
      expect(averageMinor(1000, 0), 0);
    });
  });
}
