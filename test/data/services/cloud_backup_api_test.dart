import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/data/services/cloud_backup_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const String token = 'abcdefghjkmnpqrstuvwxyz2';

CloudBackupApi apiAnswering(
  Future<http.Response> Function(http.Request request) answer, {
  Duration timeout = const Duration(seconds: 5),
}) => CloudBackupApi(
  client: MockClient(answer),
  baseUrl: 'http://backup.test',
  timeout: timeout,
);

final Map<String, Object?> listJson = {
  'days': [
    {'day': '2026-11-07', 'exportedAt': 1794038400000, 'count': 214},
    {'day': '2026-11-06', 'exportedAt': 1793952000000, 'count': 210},
  ],
  'latest': {'day': '2026-11-07', 'exportedAt': 1794038400000, 'count': 214},
};

void main() {
  test(
    'an upload sends the bytes with the token, day, time and count',
    () async {
      late http.Request sent;
      final api = apiAnswering((request) async {
        sent = request;
        return http.Response('{"ok":true}', 200);
      });
      final result = await api.upload(
        token: token,
        bytes: [0x1f, 0x8b, 1, 2],
        day: '2026-11-07',
        exportedAt: 1794038400000,
        count: 214,
      );
      expect(result.value, isTrue);
      expect(sent.method, 'PUT');
      expect(sent.url.toString(), 'http://backup.test/backup');
      expect(sent.headers['authorization'], 'Bearer $token');
      expect(sent.headers['x-day'], '2026-11-07');
      expect(sent.headers['x-exported-at'], '1794038400000');
      expect(sent.headers['x-count'], '214');
      expect(sent.bodyBytes, [0x1f, 0x8b, 1, 2]);
    },
  );

  test('the list reads back the days and the latest', () async {
    late http.Request sent;
    final api = apiAnswering((request) async {
      sent = request;
      return http.Response(jsonEncode(listJson), 200);
    });
    final listing = (await api.list(token)).value!;
    expect(sent.method, 'GET');
    expect(sent.url.path, '/backups');
    expect(sent.headers['authorization'], 'Bearer $token');
    expect(listing.days.map((c) => c.day), ['2026-11-07', '2026-11-06']);
    expect(listing.days.first.count, 214);
    expect(listing.latest!.exportedAt, 1794038400000);
  });

  test('an empty cloud lists nothing', () async {
    final api = apiAnswering(
      (_) async => http.Response('{"days":[],"latest":null}', 200),
    );
    final listing = (await api.list(token)).value!;
    expect(listing.days, isEmpty);
    expect(listing.latest, isNull);
    expect(listing.restorable, isEmpty);
  });

  test('a download asks for the day by name and returns its bytes', () async {
    late http.Request sent;
    final api = apiAnswering((request) async {
      sent = request;
      return http.Response.bytes([0x1f, 0x8b, 9], 200);
    });
    final result = await api.download(token, '2026-11-06');
    expect(sent.url.path, '/backups/2026-11-06');
    expect(result.value, [0x1f, 0x8b, 9]);
  });

  group('failures come back typed, never thrown', () {
    Future<CloudFailure?> failureOf(CloudBackupApi api) async =>
        (await api.list(token)).failure;

    test('401 is a wrong token', () async {
      final api = apiAnswering((_) async => http.Response('{}', 401));
      expect(await failureOf(api), CloudFailure.wrongToken);
    });

    test('a server error is no answer', () async {
      final api = apiAnswering((_) async => http.Response('oops', 500));
      expect(await failureOf(api), CloudFailure.noAnswer);
    });

    test('no network is no connection', () async {
      final api = apiAnswering(
        (_) async => throw const SocketException('Failed host lookup'),
      );
      expect(await failureOf(api), CloudFailure.noConnection);
      final refused = apiAnswering(
        (_) async => throw http.ClientException('Connection refused'),
      );
      expect(await failureOf(refused), CloudFailure.noConnection);
    });

    test('a slow reply is no answer', () async {
      final api = apiAnswering(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 10),
      );
      expect(await failureOf(api), CloudFailure.noAnswer);
    });

    test('a broken or wrongly shaped list is no answer', () async {
      for (final body in [
        'not json',
        '[]',
        '{"days":"x","latest":null}',
        '{"days":[{"day":"2026-11-07"}],"latest":null}',
        '{"days":[],"latest":{"day":1}}',
      ]) {
        final api = apiAnswering((_) async => http.Response(body, 200));
        expect(await failureOf(api), CloudFailure.noAnswer, reason: body);
      }
    });
  });

  group('what Restore offers', () {
    const today = CloudCopy(day: '2026-11-07', exportedAt: 7, count: 214);
    const yesterday = CloudCopy(day: '2026-11-06', exportedAt: 6, count: 210);

    test('the latest is left out while its day is kept', () {
      const latest = CloudCopy(day: '2026-11-07', exportedAt: 7, count: 214);
      const listing = CloudListing(days: [today, yesterday], latest: latest);
      expect(listing.restorable, [today, yesterday]);
      expect(copyName(listing, today), '2026-11-07');
    });

    test('the latest comes first once its day has expired', () {
      const old = CloudCopy(day: '2026-08-01', exportedAt: 1, count: 90);
      const listing = CloudListing(days: [], latest: old);
      expect(listing.restorable, [old]);
      expect(copyName(listing, old), 'latest');
    });
  });
}
