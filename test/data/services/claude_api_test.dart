import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:expense_tracker/data/services/claude_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final Uint8List png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  ...List.filled(32, 7),
]);

http.Response ok(Map<String, Object?> answer) => http.Response(
  jsonEncode({
    'stop_reason': 'end_turn',
    'content': [
      {'type': 'text', 'text': jsonEncode(answer)},
    ],
  }),
  200,
);

const Map<String, Object?> answer = {
  'amount_sen': 3186,
  'merchant': 'Kedai Ali',
  'date': '2026-11-06',
  'delivery': false,
};

void main() {
  test('sends the picture with the key, schema and low effort', () async {
    late http.Request sent;
    final api = ClaudeApi(
      client: MockClient((request) async {
        sent = request;
        return ok(answer);
      }),
    );
    final reading = await api.readReceipt(key: 'sk-test', image: png);

    expect(reading?.amountMinor, 3186);
    expect(sent.url.toString(), 'https://api.anthropic.com/v1/messages');
    expect(sent.headers['x-api-key'], 'sk-test');
    expect(sent.headers['anthropic-version'], '2026-10-21');
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body['model'], 'claude-haiku-5-5');
    // Haiku takes no server-side fallback: sending one is refused.
    expect(body.containsKey('fallbacks'), isFalse);
    expect(sent.headers.containsKey('anthropic-beta'), isFalse);
    expect(body['output_config']['effort'], 'low');
    expect(body['output_config']['format']['type'], 'json_schema');
    final image = body['messages'][0]['content'][0] as Map<String, dynamic>;
    expect(image['source']['media_type'], 'image/png');
    expect(base64Decode(image['source']['data'] as String), png);
  });

  test('a report review sends the brief and returns the text', () async {
    late http.Request sent;
    final api = ClaudeApi(
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'stop_reason': 'end_turn',
            'content': [
              {'type': 'thinking', 'thinking': ''},
              {'type': 'text', 'text': '  Food led the month.\n'},
            ],
          }),
          200,
        );
      }),
    );
    final review = await api.reviewReport(key: 'k', brief: 'Spent: RM1.00');

    expect(review, 'Food led the month.');
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body['messages'][0]['content'], 'Spent: RM1.00');
    expect(body['output_config'], {'effort': 'low'});
  });

  test('a review that was refused or empty gives nothing', () async {
    for (final reply in [
      {
        'stop_reason': 'refusal',
        'content': [
          {'type': 'text', 'text': 'x'},
        ],
      },
      {
        'stop_reason': 'end_turn',
        'content': [
          {'type': 'text', 'text': '  '},
        ],
      },
    ]) {
      final api = ClaudeApi(
        client: MockClient((_) async => http.Response(jsonEncode(reply), 200)),
      );
      expect(await api.reviewReport(key: 'k', brief: 'b'), isNull);
    }
  });

  test('an error status gives nothing', () async {
    for (final status in [400, 401, 429, 500, 529]) {
      final api = ClaudeApi(
        client: MockClient((_) async => http.Response('{}', status)),
      );
      expect(await api.readReceipt(key: 'k', image: png), isNull);
    }
  });

  test('a key a header cannot carry gives nothing', () async {
    final api = ClaudeApi(
      client: MockClient((request) async {
        // As the real client does for a non-ASCII header value.
        throw ArgumentError('Invalid HTTP header field value');
      }),
    );
    expect(await api.readReceipt(key: 'sk-\u{200B}k', image: png), isNull);
  });

  test('no network gives nothing', () async {
    final api = ClaudeApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    expect(await api.readReceipt(key: 'k', image: png), isNull);
  });

  test('a body that is not JSON gives nothing', () async {
    final api = ClaudeApi(
      client: MockClient((_) async => http.Response('<html>', 200)),
    );
    expect(await api.readReceipt(key: 'k', image: png), isNull);
  });

  test('a picture type the API does not take is never sent', () async {
    var calls = 0;
    final api = ClaudeApi(
      client: MockClient((_) async {
        calls++;
        return ok(answer);
      }),
    );
    final heic = Uint8List.fromList([0, 0, 0, 0x18, ...'ftypheic'.codeUnits]);
    expect(await api.readReceipt(key: 'k', image: heic), isNull);
    expect(calls, 0);
  });

  test('a reply slower than the timeout is dropped', () async {
    final api = ClaudeApi(
      client: MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 50),
    );
    expect(await api.readReceipt(key: 'k', image: png), isNull);
  });

  test('the app waits 15 seconds', () {
    expect(ClaudeApi().timeout, const Duration(seconds: 15));
  });
}
