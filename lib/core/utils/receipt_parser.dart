import 'money.dart';

/// One line of text read from a picture, with where it sits (pixels, top
/// down).
typedef ReadLine = ({String text, double top, double bottom, double left});

/// What a receipt screenshot gave: any of it may be missing.
///
/// [labels] are the page's printed words (`order details`, `item
/// subtotal`), which tell one kind of receipt page from another.
typedef ReceiptReading = ({
  int? amountMinor,
  String? shop,
  DateTime? date,
  bool delivery,
  Set<String> labels,
});

// `RM14.60`, `RM 1,234.50`, `-RM7.00`; the minus marks a discount.
final RegExp _money = RegExp(
  r'(-\s*)?RM\s?(\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

// Labels of the amount actually paid. `Subtotal` is not one: `\btotal`
// needs a word break before `total`.
final RegExp _totalLabel = RegExp(
  r'\b(total|grand total|amount paid|you paid|total paid|jumlah|'
  r'amount|payment amount|total amount)\b',
  caseSensitive: false,
);

// Labels whose next line is the shop.
final RegExp _shopLabel = RegExp(
  r'^(take from|from|merchant|merchant name|store|shop|restaurant|'
  r'paid to|pay to|receiver|recipient|recipient name|beneficiary name)'
  r'\s*:?\s*$',
  caseSensitive: false,
);

// The same labels with the shop after them on one line: `Merchant: Kedai`.
final RegExp _shopInline = RegExp(
  r'^(merchant|merchant name|paid to|pay to|receiver|recipient|'
  r'recipient name|beneficiary name|store|shop|restaurant)\s*:\s*(.+)$',
  caseSensitive: false,
);

// A delivery order: its fee line, or the `Deliver to` address heading.
final RegExp _delivery = RegExp(
  r'\b(delivery fee|deliver to)\b',
  caseSensitive: false,
);

/// An amount set this many times taller than the page's usual text is the
/// big figure payment screens print what you paid in.
const double _bigAmount = 1.4;

const List<String> _months = [
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec',
];

// `24 Oct 2026`, `24 October 2026`
final RegExp _dayMonthYear = RegExp(
  r'\b(\d{1,2})\s+([A-Za-z]{3,9})\.?,?\s+(\d{4})\b',
);
// `Oct 24, 2026`
final RegExp _monthDayYear = RegExp(
  r'\b([A-Za-z]{3,9})\.?\s+(\d{1,2}),?\s+(\d{4})\b',
);
// `24/10/2026`, `24-10-2026` (day first, as in Malaysia)
final RegExp _numericDate = RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{4})\b');
// `2026-10-24`
final RegExp _isoDate = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b');

/// Reads a payment or order screenshot's [lines]: the amount paid, the shop,
/// the date, and whether it was a delivery (it has a delivery fee).
///
/// The amount is the one beside a total label (the lowest such, since a
/// final total sits under subtotals). Without a label, it is the topmost
/// big amount standing alone on its line, as payment screens print what you
/// paid large near the top (an ad's big figure comes lower). Failing both,
/// the lowest amount that is not a discount, as order screens put what you
/// paid last.
/// The shop is the line under (or after) a label such as `Take from` or
/// `Paid to`.
ReceiptReading parseReceipt(List<ReadLine> lines) {
  final sorted = [...lines]..sort((a, b) => a.top.compareTo(b.top));
  return (
    amountMinor: _amount(sorted),
    shop: _shop(sorted),
    date: _date(sorted),
    delivery: sorted.any((line) => _delivery.hasMatch(line.text)),
    labels: _labels(sorted),
  );
}

/// The page's printed labels, leaving out the shop, which changes from one
/// receipt to the next.
Set<String> _labels(List<ReadLine> lines) {
  final shop = _shop(lines);
  final shopLabel = shop == null ? null : _label(shop);
  return {
    for (final line in lines)
      if (_label(line.text) case final label? when label != shopLabel) label,
  };
}

/// The most words a line can have and still be a label, not a sentence.
const int _labelMaxWords = 5;

/// [text] as a label (lower case, letters only, brackets dropped since they
/// hold counts: `Item Subtotal (1 item)` -> `item subtotal`), or null for
/// amounts, dates and long lines.
String? _label(String text) {
  if (_money.hasMatch(text) || _dateIn(text) != null) return null;
  final words = text
      .toLowerCase()
      .replaceAll(RegExp(r'\([^)]*\)'), ' ')
      .replaceAll(RegExp('[^a-z]+'), ' ')
      .trim()
      .split(' ')
      .where((word) => word.length > 1)
      .toList();
  if (words.isEmpty || words.length > _labelMaxWords) return null;
  return words.join(' ');
}

int? _amount(List<ReadLine> lines) {
  final usual = _usualHeight(lines);
  int? labelled;
  int? lowest;
  int? big;
  for (final line in lines) {
    final own = _paid(line.text);
    if (own != null) lowest = own;
    if (own != null &&
        big == null &&
        _alone(line.text) &&
        line.bottom - line.top >= usual * _bigAmount) {
      big = own;
    }
    if (!_totalLabel.hasMatch(line.text)) continue;
    // The amount is on the label's line, or on the same row to its right.
    final beside = own ?? _rowAmount(lines, line);
    if (beside != null) labelled = beside;
  }
  return labelled ?? big ?? lowest;
}

/// The median line height: the page's usual text size.
double _usualHeight(List<ReadLine> lines) {
  if (lines.isEmpty) return 0;
  final heights = [for (final line in lines) line.bottom - line.top]..sort();
  return heights[heights.length ~/ 2];
}

/// Whether [text] is nothing but an amount (`RM 12.40`).
bool _alone(String text) => text.replaceAll(_money, '').trim().isEmpty;

/// An amount paid in [text]: the last one that is not a discount.
int? _paid(String text) {
  int? found;
  for (final match in _money.allMatches(text)) {
    if (match.group(1) != null) continue;
    final minor = parseToMinor(match.group(2)!);
    if (minor > 0) found = minor;
  }
  return found;
}

int? _rowAmount(List<ReadLine> lines, ReadLine label) {
  int? found;
  for (final line in _rightOf(lines, label)) {
    found = _paid(line.text) ?? found;
  }
  return found;
}

/// The lines on [label]'s row, to its right: a value laid out beside its
/// label (`Merchant      Kedai Runcit`).
Iterable<ReadLine> _rightOf(List<ReadLine> lines, ReadLine label) {
  final middle = (label.top + label.bottom) / 2;
  final reach = (label.bottom - label.top) / 2;
  return lines.where(
    (line) =>
        !identical(line, label) &&
        line.left > label.left &&
        ((line.top + line.bottom) / 2 - middle).abs() <= reach,
  );
}

String? _shop(List<ReadLine> lines) {
  for (final line in lines) {
    final text = line.text.trim();
    final inline = _shopInline.firstMatch(text);
    if (inline != null) return inline.group(2)!.trim();
    if (!_shopLabel.hasMatch(text)) continue;
    // Beside the label first, else the first line under it.
    final beside = _rightOf(lines, line).map((l) => l.text.trim());
    final below = lines
        .where((l) => l.top >= line.bottom - 1)
        .map((l) => l.text.trim());
    for (final name in [...beside, ...below]) {
      if (name.isNotEmpty && !_money.hasMatch(name)) return name;
    }
  }
  return null;
}

DateTime? _date(List<ReadLine> lines) {
  for (final line in lines) {
    final date = _dateIn(line.text);
    if (date != null) return date;
  }
  return null;
}

DateTime? _dateIn(String text) {
  final dmy = _dayMonthYear.firstMatch(text);
  if (dmy != null) {
    final month = _month(dmy.group(2)!);
    if (month != null) {
      return _valid(int.parse(dmy.group(3)!), month, int.parse(dmy.group(1)!));
    }
  }
  final mdy = _monthDayYear.firstMatch(text);
  if (mdy != null) {
    final month = _month(mdy.group(1)!);
    if (month != null) {
      return _valid(int.parse(mdy.group(3)!), month, int.parse(mdy.group(2)!));
    }
  }
  final iso = _isoDate.firstMatch(text);
  if (iso != null) {
    return _valid(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }
  final numeric = _numericDate.firstMatch(text);
  if (numeric != null) {
    return _valid(
      int.parse(numeric.group(3)!),
      int.parse(numeric.group(2)!),
      int.parse(numeric.group(1)!),
    );
  }
  return null;
}

int? _month(String name) {
  final index = _months.indexOf(name.toLowerCase().substring(0, 3));
  return index < 0 ? null : index + 1;
}

/// The date, or null when the numbers are not a real day (`31/02/2026`).
DateTime? _valid(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1) return null;
  final date = DateTime(year, month, day);
  return date.month == month ? date : null;
}
