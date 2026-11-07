import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/app_info.dart';

/// Why a call to the backup Worker gave nothing.
enum CloudFailure {
  /// The Worker turned the token down.
  wrongToken,

  /// The phone could not reach it.
  noConnection,

  /// It answered with an error, too slowly, or with something unreadable.
  noAnswer,
}

/// What a call to the Worker gave: [value] when it worked, else [failure].
class CloudResult<T> {
  const CloudResult.ok(T this.value) : failure = null;
  const CloudResult.failed(CloudFailure this.failure) : value = null;

  final T? value;
  final CloudFailure? failure;
}

/// One kept copy: its day (`YYYY-MM-DD`, the phone's day), when it was
/// exported and how many expenses it holds.
class CloudCopy {
  const CloudCopy({
    required this.day,
    required this.exportedAt,
    required this.count,
  });

  final String day;
  final int exportedAt;
  final int count;
}

/// The kept days, newest first, and the latest copy (null before any).
class CloudListing {
  const CloudListing({required this.days, required this.latest});

  final List<CloudCopy> days;
  final CloudCopy? latest;

  /// What Restore offers: every kept day, and the latest copy only when its
  /// own day has expired (otherwise it is that day's copy again).
  List<CloudCopy> get restorable {
    final latest = this.latest;
    if (latest == null || days.any((copy) => copy.day == latest.day)) {
      return days;
    }
    return [latest, ...days];
  }
}

/// The name a copy is fetched by: `latest` when it is the latest copy and
/// its day is no longer kept, else its day.
String copyName(CloudListing listing, CloudCopy copy) =>
    listing.days.contains(copy) ? copy.day : 'latest';

/// Talks to the backup Worker (`backup-worker/`) over plain HTTP. Never
/// throws: every failure comes back as a [CloudFailure].
class CloudBackupApi {
  CloudBackupApi({
    http.Client? client,
    String baseUrl = kBackupUrl,
    this.timeout = kCloudBackupTimeout,
  }) : _client = client ?? http.Client(),
       _base = Uri.parse(baseUrl);

  final http.Client _client;
  final Uri _base;
  final Duration timeout;

  Future<CloudResult<bool>> upload({
    required String token,
    required List<int> bytes,
    required String day,
    required int exportedAt,
    required int count,
  }) => _call(
    () => _client.put(
      _base.resolve('/backup'),
      headers: {
        ..._auth(token),
        'content-type': 'application/gzip',
        'x-day': day,
        'x-exported-at': '$exportedAt',
        'x-count': '$count',
      },
      body: bytes,
    ),
    (response) => true,
  );

  Future<CloudResult<CloudListing>> list(String token) => _call(
    () => _client.get(_base.resolve('/backups'), headers: _auth(token)),
    (response) => _listing(jsonDecode(utf8.decode(response.bodyBytes))),
  );

  /// The copy's gzipped bytes; [name] is a day or `latest`.
  Future<CloudResult<List<int>>> download(String token, String name) => _call(
    () => _client.get(_base.resolve('/backups/$name'), headers: _auth(token)),
    (response) => response.bodyBytes,
  );

  Map<String, String> _auth(String token) => {'authorization': 'Bearer $token'};

  Future<CloudResult<T>> _call<T>(
    Future<http.Response> Function() send,
    T Function(http.Response response) read,
  ) async {
    try {
      final response = await send().timeout(timeout);
      if (response.statusCode == 401) {
        return const CloudResult.failed(CloudFailure.wrongToken);
      }
      if (response.statusCode != 200) {
        return const CloudResult.failed(CloudFailure.noAnswer);
      }
      return CloudResult.ok(read(response));
    } on TimeoutException {
      return const CloudResult.failed(CloudFailure.noAnswer);
    } on SocketException {
      return const CloudResult.failed(CloudFailure.noConnection);
    } on http.ClientException {
      // How `http` reports a refused or dropped connection.
      return const CloudResult.failed(CloudFailure.noConnection);
    } on FormatException {
      return const CloudResult.failed(CloudFailure.noAnswer);
    }
  }
}

/// The Worker's list; a [FormatException] for anything not its shape.
CloudListing _listing(Object? decoded) {
  if (decoded case {'days': final List<dynamic> days, 'latest': final latest}) {
    final copies = days.map(_copy).toList();
    final latestCopy = latest == null ? null : _copy(latest);
    if (!copies.contains(null) && (latest == null || latestCopy != null)) {
      return CloudListing(days: copies.cast<CloudCopy>(), latest: latestCopy);
    }
  }
  throw const FormatException('Not the backup list');
}

CloudCopy? _copy(Object? json) => switch (json) {
  {
    'day': final String day,
    'exportedAt': final int exportedAt,
    'count': final int count,
  } =>
    CloudCopy(day: day, exportedAt: exportedAt, count: count),
  _ => null,
};
