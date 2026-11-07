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

const Map<String, Object?> take = {
  'headline': 'Rent led the month.',
  'points': [
    {'text': 'Mamak 3 times.', 'category': 'Food'},
  ],
};

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

  test('sends the picture with max_tokens 4000', () async {
    late http.Request sent;
    final api = ClaudeApi(
      client: MockClient((request) async {
        sent = request;
        return ok(answer);
      }),
    );
    await api.readReceipt(key: 'k', image: png);
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body['max_tokens'], 4000);
  });

  test('a report take: Sonnet at medium, the schema, fallbacks', () async {
    late http.Request sent;
    final api = ClaudeApi(
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'stop_reason': 'end_turn',
            'content': [
              {'type': 'thinking', 'thinking': ''},
              {'type': 'text', 'text': jsonEncode(take)},
            ],
          }),
          200,
        );
      }),
    );
    final review = await api.reviewReport(
      key: 'sk-test',
      brief: 'Period: November 2026',
      categories: {'Food', 'Rent'},
    );

    expect(review?.headline, 'Rent led the month.');
    expect(review?.points.single, (text: 'Mamak 3 times.', category: 'Food'));
    expect(sent.headers['x-api-key'], 'sk-test');
    expect(sent.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body['model'], 'claude-sonnet-5-5');
    expect(body['max_tokens'], 16000);
    expect(body['fallbacks'], 'default');
    expect(body.containsKey('thinking'), isFalse);
    expect(body['messages'], [
      {'role': 'user', 'content': 'Period: November 2026'},
    ]);
    final config = body['output_config'] as Map<String, dynamic>;
    expect(config['effort'], 'medium');
    expect(config['format']['type'], 'json_schema');
    final schema = config['format']['schema'] as Map<String, dynamic>;
    expect(schema['required'], ['headline', 'points']);
    expect(schema['properties']['points']['items']['properties']['category'], {
      'type': 'string',
      'enum': ['Food', 'Rent', 'none'],
    });
  });

  test(
    'a take that was refused, cut off or off the schema gives nothing',
    () async {
      for (final reply in [
        {
          'stop_reason': 'refusal',
          'stop_details': {'type': 'refusal', 'category': 'general_harms'},
          'content': <Object>[],
        },
        {
          'stop_reason': 'max_tokens',
          'content': [
            {'type': 'text', 'text': '{"headline": "Rent'},
          ],
        },
        {
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'text', 'text': 'Rent led the month.'},
          ],
        },
      ]) {
        final api = ClaudeApi(
          client: MockClient(
            (_) async => http.Response(jsonEncode(reply), 200),
          ),
        );
        expect(
          await api.reviewReport(key: 'k', brief: 'b', categories: {'Food'}),
          isNull,
        );
      }
    },
  );

  test('a take after a fallback reads the answer, not the switch', () async {
    final api = ClaudeApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'stop_reason': 'end_turn',
            'model': 'claude-sonnet-5',
            'content': [
              {
                'type': 'fallback',
                'from': {'model': 'claude-sonnet-5-5'},
                'to': {'model': 'claude-sonnet-5'},
              },
              {'type': 'text', 'text': jsonEncode(take)},
            ],
          }),
          200,
        ),
      ),
    );
    final review = await api.reviewReport(
      key: 'k',
      brief: 'b',
      categories: {'Food'},
    );
    expect(review?.headline, 'Rent led the month.');
  });

  test('a take with an error status or no network gives nothing', () async {
    for (final client in [
      MockClient((_) async => http.Response('{}', 529)),
      MockClient((_) async => throw http.ClientException('offline')),
    ]) {
      final api = ClaudeApi(client: client);
      expect(
        await api.reviewReport(key: 'k', brief: 'b', categories: {'Food'}),
        isNull,
      );
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

  test('each call drops a reply slower than its own timeout', () async {
    final api = ClaudeApi(
      client: MockClient((_) => Completer<http.Response>().future),
      receiptTimeout: const Duration(milliseconds: 50),
      reportTimeout: const Duration(milliseconds: 50),
    );
    expect(await api.readReceipt(key: 'k', image: png), isNull);
    expect(
      await api.reviewReport(key: 'k', brief: 'b', categories: {'Food'}),
      isNull,
    );
  });

  test('screenshots wait 15 seconds, the report 60', () {
    final api = ClaudeApi();
    expect(api.receiptTimeout, const Duration(seconds: 15));
    expect(api.reportTimeout, const Duration(seconds: 60));
  });

  test('a slow take still comes within the report timeout', () async {
    final api = ClaudeApi(
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        return http.Response(
          jsonEncode({
            'stop_reason': 'end_turn',
            'content': [
              {'type': 'text', 'text': jsonEncode(take)},
            ],
          }),
          200,
        );
      }),
      receiptTimeout: const Duration(milliseconds: 20),
      reportTimeout: const Duration(seconds: 5),
    );
    expect(
      await api.reviewReport(key: 'k', brief: 'b', categories: {'Food'}),
      isNotNull,
    );
  });
}
