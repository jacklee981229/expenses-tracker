/// Keypad input rules for the amount on the add expense sheet. The expression
/// is operands joined by [kPlus] or [kMinus], e.g. `12.50+3`. It is evaluated
/// in integer sen by `evaluateAmountExpression` in money.dart.
library;

import 'package:flutter/services.dart';

import '../constants/strings.dart';
import 'money.dart';

const String kPlus = '+';
const String kMinus = '-';
const String _point = '.';
const int _maxDecimals = 2;

final RegExp _operators = RegExp(r'[+-]');

/// For plain amount text fields: digits, one point, two decimals at most.
final TextInputFormatter amountInputFormatter =
    FilteringTextInputFormatter.allow(
      RegExp('^\\d{0,$kMaxAmountIntegerDigits}(\\.\\d{0,$_maxDecimals})?'),
    );

String _currentOperand(String expression) =>
    expression.substring(expression.lastIndexOf(_operators) + 1);

bool hasOperator(String expression) => expression.contains(_operators);

/// Appends [digit], enforcing two decimal places and the integer digit limit.
String appendDigit(String expression, String digit) {
  final operand = _currentOperand(expression);
  final point = operand.indexOf(_point);
  if (point >= 0) {
    final decimals = operand.length - point - 1;
    return decimals >= _maxDecimals ? expression : expression + digit;
  }
  if (operand == '0') {
    return expression.substring(0, expression.length - 1) + digit;
  }
  if (operand.length >= kMaxAmountIntegerDigits) return expression;
  return expression + digit;
}

String appendDecimalPoint(String expression) {
  final operand = _currentOperand(expression);
  if (operand.contains(_point)) return expression;
  return operand.isEmpty ? '${expression}0$_point' : '$expression$_point';
}

/// Appends the operator [symbol]; a second operator in a row replaces the
/// first.
String appendOperator(String expression, String symbol) {
  if (expression.isEmpty) return expression;
  final last = expression[expression.length - 1];
  final base = (last == kPlus || last == kMinus)
      ? expression.substring(0, expression.length - 1)
      : expression;
  return base + symbol;
}

String removeLastCharacter(String expression) => expression.isEmpty
    ? expression
    : expression.substring(0, expression.length - 1);

/// `12.50+3-1` -> `12.50 + 3 − 1`.
String displayExpression(String expression) => expression
    .replaceAll(kPlus, ' ${AppStrings.keyPlus} ')
    .replaceAll(kMinus, ' ${AppStrings.keyMinus} ');
