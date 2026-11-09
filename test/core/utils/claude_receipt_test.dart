import 'dart:convert';
import 'dart:typed_data';

import 'package:expense_tracker/core/utils/claude_receipt.dart';
import 'package:expense_tracker/core/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Messages API reply whose text block holds [answer] as JSON.
Map<String, dynamic> reply(
  Object? answer, {
  String stopReason = 'end_turn',
  List<Map<String, dynamic>> before = const [],
}) => {
  'type': 'message',
  'stop_reason': stopReason,
  'content': [
    ...before,
    {'type': 'thinking', 'thinking': ''},
    {'type': 'text', 'text': answer is String ? answer : jsonEncode(answer)},
  ],
};

const Map<String, Object?> fullAnswer = {
  'amount_sen': 1160,
  'merchant': 'Ayam Goreng Corner',
  'date': '2026-11-06',
  'delivery': true,
};

final ReceiptReading onPhone = (
  amountMinor: 1460,
  shop: 'Ayam Goreng Corner - Mid Valley',
  date: DateTime(2026, 11, 5),
  delivery: false,
);

void main() {
  group('parseClaudeReply', () {
    test('reads amount in sen, merchant, date and delivery', () {
      final reading = parseClaudeReply(reply(fullAnswer))!;
      expect(reading.amountMinor, 1160);
      expect(reading.shop, 'Ayam Goreng Corner');
      expect(reading.date, DateTime(2026, 11, 6));
      expect(reading.delivery, isTrue);
    });

    test('missing fields come back null', () {
      final reading = parseClaudeReply(
        reply({
          'amount_sen': null,
          'merchant': null,
          'date': null,
          'delivery': false,
        }),
      )!;
      expect(reading.amountMinor, isNull);
      expect(reading.shop, isNull);
      expect(reading.date, isNull);
      expect(reading.delivery, isFalse);
    });

    test('drops a zero or negative amount, a blank merchant, a bad date', () {
      for (final amount in [0, -3186]) {
        final reading = parseClaudeReply(
          reply({...fullAnswer, 'amount_sen': amount}),
        )!;
        expect(reading.amountMinor, isNull, reason: '$amount');
      }
      expect(
        parseClaudeReply(reply({...fullAnswer, 'merchant': '  '}))!.shop,
        isNull,
      );
      for (final date in ['2026-02-31', '6/11/2026', '2026-11-06T10:00']) {
        expect(
          parseClaudeReply(reply({...fullAnswer, 'date': date}))!.date,
          isNull,
          reason: date,
        );
      }
    });

    test('an amount sent as a decimal is not taken', () {
      // Sen are whole; 11.6 means Claude gave ringgit by mistake.
      expect(
        parseClaudeReply(
          reply({...fullAnswer, 'amount_sen': 11.6}),
        )!.amountMinor,
        isNull,
      );
    });

    test('trims the merchant', () {
      expect(
        parseClaudeReply(
          reply({...fullAnswer, 'merchant': ' Kedai Ali '}),
        )!.shop,
        'Kedai Ali',
      );
    });

    test('a refusal gives nothing', () {
      expect(
        parseClaudeReply(reply(fullAnswer, stopReason: 'refusal')),
        isNull,
      );
    });

    test('a reply cut off at max_tokens gives nothing', () {
      expect(
        parseClaudeReply(
          reply('{"amount_sen": 1160, "merch', stopReason: 'max_tokens'),
        ),
        isNull,
      );
    });

    test('text that is not the JSON object gives nothing', () {
      expect(parseClaudeReply(reply('RM11.60 at Ayam Goreng')), isNull);
      expect(parseClaudeReply(reply('[1160]')), isNull);
      expect(parseClaudeReply({'stop_reason': 'end_turn'}), isNull);
      expect(
        parseClaudeReply({'stop_reason': 'end_turn', 'content': []}),
        isNull,
      );
    });

    test('after a server-side fallback the answer is the last text', () {
      final reading = parseClaudeReply(
        reply(
          fullAnswer,
          before: [
            {'type': 'text', 'text': ''},
            {
              'type': 'fallback',
              'from': {'model': 'a'},
              'to': {'model': 'b'},
            },
          ],
        ),
      );
      expect(reading?.amountMinor, 1160);
    });
  });

  group('mergeReadings', () {
    test("Claude's figures replace the phone's", () {
      final merged = mergeReadings(onPhone, (
        amountMinor: 1160,
        shop: 'Ayam Goreng Corner',
        date: DateTime(2026, 11, 6),
        delivery: true,
      ));
      expect(merged.amountMinor, 1160);
      expect(merged.shop, 'Ayam Goreng Corner');
      expect(merged.date, DateTime(2026, 11, 6));
      expect(merged.delivery, isTrue);
    });

    test("what Claude missed keeps the phone's reading", () {
      final merged = mergeReadings(onPhone, (
        amountMinor: null,
        shop: null,
        date: null,
        delivery: false,
      ));
      expect(merged.amountMinor, 1460);
      expect(merged.shop, onPhone.shop);
      expect(merged.date, onPhone.date);
      expect(merged.delivery, isFalse);
    });

    test('no Claude reading is the phone reading as it is', () {
      expect(mergeReadings(onPhone, null), same(onPhone));
    });
  });

  group('imageMediaType', () {
    Uint8List bytes(List<int> head) =>
        Uint8List.fromList([...head, ...List.filled(16, 0)]);

    test('knows PNG, JPEG, GIF and WebP by their first bytes', () {
      expect(imageMediaType(bytes([0x89, 0x50, 0x4E, 0x47])), 'image/png');
      expect(imageMediaType(bytes([0xFF, 0xD8, 0xFF, 0xE0])), 'image/jpeg');
      expect(imageMediaType(bytes([0x47, 0x49, 0x46, 0x38])), 'image/gif');
      expect(
        imageMediaType(
          bytes([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits]),
        ),
        'image/webp',
      );
    });

    test('anything else, HEIC included, is not sent', () {
      // HEIC: `....ftypheic`
      expect(
        imageMediaType(bytes([0, 0, 0, 0x18, ...'ftypheic'.codeUnits])),
        isNull,
      );
      expect(imageMediaType(bytes([...'RIFF'.codeUnits, 0, 0, 0, 0])), isNull);
      expect(imageMediaType(Uint8List(2)), isNull);
    });
  });
}
