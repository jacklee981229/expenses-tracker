import 'dart:convert';
import 'dart:typed_data';

import 'receipt_parser.dart';

/// What Claude read from a screenshot; null fields it could not find.
typedef ClaudeReading = ({
  int? amountMinor,
  String? shop,
  DateTime? date,
  bool delivery,
});

/// The API takes these four picture types; anything else (say HEIC) stays
/// with the phone's own reading.
String? imageMediaType(Uint8List bytes) {
  bool starts(List<int> magic, [int at = 0]) {
    if (bytes.length < at + magic.length) return false;
    for (var i = 0; i < magic.length; i++) {
      if (bytes[at + i] != magic[i]) return false;
    }
    return true;
  }

  if (starts(const [0x89, 0x50, 0x4E, 0x47])) return 'image/png';
  if (starts(const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (starts(const [0x47, 0x49, 0x46, 0x38])) return 'image/gif';
  // `RIFF....WEBP`
  if (starts(const [0x52, 0x49, 0x46, 0x46]) &&
      starts(const [0x57, 0x45, 0x42, 0x50], 8)) {
    return 'image/webp';
  }
  return null;
}

const String kReceiptPrompt =
    'You read one screenshot from a phone in Malaysia: a payment, an '
    'e-wallet transfer, a food or shopping order, or a delivery being '
    'tracked. Fill in what it shows, and null for anything it does not '
    'show. Amounts are in ringgit (RM).';

Map<String, Object> _nullable(Map<String, Object> type) => {
  'anyOf': [
    type,
    {'type': 'null'},
  ],
};

/// The reply's shape, so it is parsed as JSON, never picked out of prose.
final Map<String, Object> kReceiptSchema = {
  'type': 'object',
  'properties': {
    'amount_sen': _nullable({
      'type': 'integer',
      'description':
          'What the user paid, in sen (RM14.60 is 1460): the final total of '
          'an order, or the amount of a payment or transfer. A minus sign '
          'shown on a payment is not part of the amount.',
    }),
    'merchant': _nullable({
      'type': 'string',
      'description':
          'Who was paid: the shop, restaurant or person, as named on the '
          'screen, without an address or order number.',
    }),
    'date': _nullable({
      'type': 'string',
      'format': 'date',
      'description': 'The date of the payment or order.',
    }),
    'delivery': {
      'type': 'boolean',
      'description':
          'True for a food or goods order being delivered to the user '
          '(a delivery fee, a deliver-to address, or delivery tracking).',
    },
  },
  'required': ['amount_sen', 'merchant', 'date', 'delivery'],
  'additionalProperties': false,
};

/// Reads a Messages API reply [body]. Null when Claude declined, was cut
/// off, or sent something other than the schema's JSON.
ClaudeReading? parseClaudeReply(Map<String, dynamic> body) {
  final text = replyText(body);
  if (text == null) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic>) return null;

  final amount = decoded['amount_sen'];
  final shop = decoded['merchant'];
  final date = decoded['date'];
  return (
    amountMinor: amount is int && amount > 0 ? amount : null,
    shop: shop is String && shop.trim().isNotEmpty ? shop.trim() : null,
    date: date is String ? _date(date) : null,
    delivery: decoded['delivery'] == true,
  );
}

/// The answer in a Messages API reply [body]: its last text block, trimmed.
/// Null when Claude declined, was cut off, or wrote nothing.
String? replyText(Map<String, dynamic> body) {
  if (body['stop_reason'] != 'end_turn') return null;
  final content = body['content'];
  if (content is! List) return null;
  // Thinking and other blocks may come first; the answer is the last text.
  final text = content
      .whereType<Map<String, dynamic>>()
      .where((block) => block['type'] == 'text')
      .map((block) => block['text'])
      .whereType<String>()
      .lastOrNull
      ?.trim();
  return text == null || text.isEmpty ? null : text;
}

// `2026-11-06` only, as a local date.
DateTime? _date(String text) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  // DateTime rolls 2026-02-31 over into March; that is no date.
  if (date.month != month || date.day != day) return null;
  return date;
}

/// The phone's [reading] with Claude's figures in place of its own where
/// Claude found them.
ReceiptReading mergeReadings(ReceiptReading reading, ClaudeReading? claude) {
  if (claude == null) return reading;
  return (
    amountMinor: claude.amountMinor ?? reading.amountMinor,
    shop: claude.shop ?? reading.shop,
    date: claude.date ?? reading.date,
    delivery: claude.delivery,
  );
}
