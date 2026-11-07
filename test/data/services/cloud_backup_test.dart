import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/utils/backup_timing.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/services/cloud_backup.dart';
import 'package:expense_tracker/data/services/cloud_backup_api.dart';
import 'package:expense_tracker/data/services/cloud_backup_store.dart';
import 'package:expense_tracker/data/services/export_service.dart';
import 'package:expense_tracker/data/services/import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The Keychain, in memory.
class MemoryTokens extends CloudBackupTokenStore {
  MemoryTokens([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;

  @override
  Future<void> delete() async => token = null;
}

/// The Worker, in memory: what was uploaded, and 401 for any other token.
class FakeWorker {
  FakeWorker(this.token);

  final String token;
  final List<http.Request> uploads = [];
  final Map<String, List<int>> copies = {};
  final Map<String, Map<String, Object>> details = {};

  Future<http.Response> answer(http.Request request) async {
    if (request.headers['authorization'] != 'Bearer $token') {
      return http.Response('{"error":"Wrong token."}', 401);
    }
    if (request.method == 'PUT') {
      uploads.add(request);
      final day = request.headers['x-day']!;
      final meta = {
        'day': day,
        'exportedAt': int.parse(request.headers['x-exported-at']!),
        'count': int.parse(request.headers['x-count']!),
      };
      copies[day] = copies['latest'] = request.bodyBytes;
      details[day] = details['latest'] = meta;
      return http.Response('{"ok":true}', 200);
    }
    if (request.url.path == '/backups') {
      return http.Response(
        jsonEncode({
          'days': [
            for (final entry in details.entries)
              if (entry.key != 'latest') entry.value,
          ],
          'latest': details['latest'],
        }),
        200,
      );
    }
    final name = request.url.pathSegments.last;
    final bytes = copies[name];
    return bytes == null
        ? http.Response('{}', 404)
        : http.Response.bytes(bytes, 200);
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const token = 'abcdefghjkmnpqrstuvwxyz2';
  late AppDatabase db;
  late Directory folder;
  late FakeWorker worker;
  late MemoryTokens tokens;
  late CloudBackupStateStore states;
  var now = DateTime(2026, 11, 7, 14, 2);

  CloudBackup cloudOn(AppDatabase database) => CloudBackup(
    api: CloudBackupApi(
      client: MockClient(worker.answer),
      baseUrl: 'http://backup.test',
    ),
    tokens: tokens,
    states: states,
    exporter: ExportService(database, clock: () => now),
    importer: ImportService(database),
    settings: database.settingsDao,
    transactions: database.transactionDao,
    clock: () => now,
  );

  Future<void> spend(AppDatabase database) async {
    final category = (await database.categoryDao.getAll()).first;
    await database.transactionDao.insertExpense(
      amountMinor: 1250,
      categoryId: category.id,
      occurredAt: DateTime(2026, 11, 7, 12),
      note: 'Lunch',
    );
  }

  setUp(() async {
    now = DateTime(2026, 11, 7, 14, 2);
    db = AppDatabase(NativeDatabase.memory());
    folder = await Directory.systemTemp.createTemp('cloud_backup_test');
    worker = FakeWorker(token);
    tokens = MemoryTokens();
    states = CloudBackupStateStore(
      file: () async => File('${folder.path}/cloud_backup.json'),
    );
  });

  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  test('a wrong token is not kept and sets nothing up', () async {
    final cloud = cloudOn(db);
    final result = await cloud.turnOn('wrong-token');
    expect(result.failure, CloudFailure.wrongToken);
    expect(tokens.token, isNull);
    expect((await states.read()).setUp, isFalse);
  });

  test('turning on checks the token with a list, never an upload', () async {
    final cloud = cloudOn(db);
    final result = await cloud.turnOn('ABCD efgh-JKMN pqrs-tuvw xyz2');
    expect(result.value, isNotNull);
    expect(tokens.token, token, reason: 'kept as the Worker compares it');
    expect((await states.read()).setUp, isTrue);
    expect(worker.uploads, isEmpty);
  });

  test(
    "hiding uploads the backup with the phone's day and sets the last export",
    () async {
      final cloud = cloudOn(db);
      await cloud.turnOn(token);
      await spend(db);
      expect(await cloud.maybeUpload(BackupMoment.hidden), isTrue);

      final upload = worker.uploads.single;
      expect(upload.headers['x-day'], '2026-11-07');
      expect(upload.headers['x-count'], '1');
      final restored = ImportService(db).parse(upload.bodyBytes);
      expect(restored.transactions.single.note, 'Lunch');
      expect(
        (await db.settingsDao.get()).lastExportAt,
        now.millisecondsSinceEpoch,
      );
      expect((await states.read()).lastGoodAt, now.millisecondsSinceEpoch);
    },
  );

  test('a second hide within 10 minutes uploads nothing', () async {
    final cloud = cloudOn(db);
    await cloud.turnOn(token);
    await spend(db);
    await cloud.maybeUpload(BackupMoment.hidden);
    now = now.add(const Duration(minutes: 9));
    expect(await cloud.maybeUpload(BackupMoment.hidden), isFalse);
    now = now.add(const Duration(minutes: 1));
    expect(await cloud.maybeUpload(BackupMoment.hidden), isTrue);
    expect(worker.uploads, hasLength(2));
  });

  test(
    'a reinstall with the token left in the Keychain uploads nothing',
    () async {
      tokens.token = token;
      await spend(db);
      final cloud = cloudOn(db);
      expect(await cloud.maybeUpload(BackupMoment.opened), isFalse);
      expect(await cloud.maybeUpload(BackupMoment.hidden), isFalse);
      expect(worker.uploads, isEmpty);
    },
  );

  test('an empty phone uploads nothing, even when set up', () async {
    final cloud = cloudOn(db);
    await cloud.turnOn(token);
    expect(await cloud.maybeUpload(BackupMoment.hidden), isFalse);
    expect((await cloud.uploadNow()).value, isFalse);
    expect(worker.uploads, isEmpty);
  });

  test(
    'a failed upload is not a good one, and the last export stays',
    () async {
      final cloud = cloudOn(db);
      await cloud.turnOn(token);
      await spend(db);
      tokens.token = 'changed-on-the-worker';
      final result = await cloud.uploadNow();
      expect(result.failure, CloudFailure.wrongToken);
      final state = await states.read();
      expect(state.lastTryAt, now.millisecondsSinceEpoch);
      expect(state.lastGoodAt, isNull);
      expect((await db.settingsDao.get()).lastExportAt, isNull);
    },
  );

  test('two uploads at once share one request', () async {
    final cloud = cloudOn(db);
    await cloud.turnOn(token);
    await spend(db);
    await Future.wait([cloud.uploadNow(), cloud.uploadNow()]);
    expect(worker.uploads, hasLength(1));
  });

  test("another phone restores a day's copy and is then set up", () async {
    final cloud = cloudOn(db);
    await cloud.turnOn(token);
    await spend(db);
    await cloud.uploadNow();

    final newPhone = AppDatabase(NativeDatabase.memory());
    addTearDown(newPhone.close);
    final otherFolder = await Directory.systemTemp.createTemp('cloud_new');
    addTearDown(() => otherFolder.delete(recursive: true));
    states = CloudBackupStateStore(
      file: () async => File('${otherFolder.path}/cloud_backup.json'),
    );
    final restoring = cloudOn(newPhone);
    expect((await states.read()).setUp, isFalse);

    final listing = (await restoring.list()).value!;
    final copy = listing.restorable.single;
    final data = (await restoring.fetch(listing, copy)).value!;
    await ImportService(newPhone).apply(data, ImportMode.replace);
    await restoring.markSetUp();

    expect(await newPhone.transactionDao.getAll(), hasLength(1));
    expect((await states.read()).setUp, isTrue);
  });

  test('turning off forgets the token and the state', () async {
    final cloud = cloudOn(db);
    await cloud.turnOn(token);
    await cloud.turnOff();
    expect(tokens.token, isNull);
    expect((await states.read()).setUp, isFalse);
  });

  test('a missing or broken state file reads as not set up', () async {
    expect((await states.read()).setUp, isFalse);
    await File('${folder.path}/cloud_backup.json').writeAsString('{broken');
    expect((await states.read()).setUp, isFalse);
    await File('${folder.path}/cloud_backup.json').writeAsString('[1]');
    expect((await states.read()).setUp, isFalse);
  });

  test('the state file keeps what was written', () async {
    await states.write(
      const CloudBackupState(setUp: true, lastTryAt: 5, lastGoodAt: 4),
    );
    final state = await states.read();
    expect(state.setUp, isTrue);
    expect(state.lastTryAt, 5);
    expect(state.lastGoodAt, 4);
  });
}
