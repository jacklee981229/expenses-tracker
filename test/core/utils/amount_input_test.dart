import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the +/- key adds a plus, then flips it to minus and back', () {
    expect(appendPlusMinus('12'), '12$kPlus');
    expect(appendPlusMinus('12$kPlus'), '12$kMinus');
    expect(appendPlusMinus('12$kMinus'), '12$kPlus');
    expect(appendPlusMinus('12${kPlus}3'), '12${kPlus}3$kPlus');
  });

  test('the +/- key does nothing on an empty amount', () {
    expect(appendPlusMinus(''), '');
  });
}
