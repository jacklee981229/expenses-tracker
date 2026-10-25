/// All conversion between money text and integer minor units (sen).
///
/// Money is an `int` everywhere in this app. It is never a `double`.
library;

import 'package:intl/intl.dart';

import '../constants/strings.dart';

/// The amount keypad accepts at most this many digits before the point.
const int kMaxAmountIntegerDigits = 9;

final NumberFormat _thousands = NumberFormat('#,##0', 'en_US');
final RegExp _amountPattern = RegExp(r'^(\d*)(?:\.(\d*))?$');

/// `'12.5'` -> `1250`. Accepts thousands separators and rounds anything past
/// two decimal places half up (`'0.005'` -> `1`). Throws [FormatException]
/// for empty, negative or non-numeric input.
int parseToMinor(String input) {
  final text = input.trim().replaceAll(',', '');
  final match = _amountPattern.firstMatch(text);
  if (match == null) throw FormatException('Not an amount', input);
  final wholeText = match.group(1)!;
  final fractionText = match.group(2) ?? '';
  if (wholeText.isEmpty && fractionText.isEmpty) {
    throw FormatException('Not an amount', input);
  }

  final whole = wholeText.isEmpty ? 0 : int.parse(wholeText);
  final padded = fractionText.padRight(3, '0');
  var cents = int.parse(padded.substring(0, 2));
  if (int.parse(padded[2]) >= 5) cents += 1;
  return whole * 100 + cents;
}

/// `1250` -> `'12.50'`, `123456` -> `'1,234.56'`. With [grouping] off:
/// `123456` -> `'1234.56'` (for CSV and editable text).
String formatMinor(int minor, {bool grouping = true}) {
  final sign = minor < 0 ? '-' : '';
  final absolute = minor.abs();
  final whole = absolute ~/ 100;
  final cents = (absolute % 100).toString().padLeft(2, '0');
  final wholeText = grouping ? _thousands.format(whole) : whole.toString();
  return '$sign$wholeText.$cents';
}

/// `1250` -> `'RM12.50'`, with no space, as Malaysian price tags write it.
String formatWithSymbol(int minor) =>
    AppStrings.withCurrency(formatMinor(minor));

final RegExp _term = RegExp(r'([+-]?)([^+-]+)');

/// Evaluates a keypad expression in sen: `'12.50+3-1'` -> `1450`. A trailing
/// operator is ignored. Returns null for an empty or malformed expression.
/// The result can be negative; callers must reject that.
int? evaluateAmountExpression(String expression) {
  var text = expression.trim();
  if (text.endsWith('+') || text.endsWith('-')) {
    text = text.substring(0, text.length - 1);
  }
  if (text.isEmpty) return null;

  var total = 0;
  var position = 0;
  for (final match in _term.allMatches(text)) {
    if (match.start != position) return null;
    position = match.end;
    final int operand;
    try {
      operand = parseToMinor(match.group(2)!);
    } on FormatException {
      return null;
    }
    total += match.group(1) == '-' ? -operand : operand;
  }
  return position == text.length ? total : null;
}

/// An expense as lists show it: `1250` -> `'-RM12.50'`.
String formatExpense(int minor) => '-${formatWithSymbol(minor)}';

final RegExp _trailingZeros = RegExp(r'0+$');

/// [part] as a share of [total], rounded half up with integer arithmetic:
/// `(4294, 10000)` -> `'42.94%'`, or `'42.9%'` with one [decimals]. With
/// [trimZeros] the fraction loses its trailing zeros, as on the donut's
/// labels: `'27.50%'` -> `'27.5%'`, `'30.00%'` -> `'30%'`.
String formatShare(
  int part,
  int total, {
  int decimals = 2,
  bool trimZeros = false,
}) {
  var scale = 1;
  for (var i = 0; i < decimals; i++) {
    scale *= 10;
  }
  final units = total <= 0 ? 0 : (part * 100 * scale + total ~/ 2) ~/ total;
  var fraction = decimals == 0
      ? ''
      : (units % scale).toString().padLeft(decimals, '0');
  if (trimZeros) fraction = fraction.replaceFirst(_trailingZeros, '');
  final whole = units ~/ scale;
  return fraction.isEmpty ? '$whole%' : '$whole.$fraction%';
}

/// [total] sen split evenly over [count], rounded half up to the sen.
/// Zero when [count] is zero.
int averageMinor(int total, int count) =>
    count <= 0 ? 0 : (total + count ~/ 2) ~/ count;
