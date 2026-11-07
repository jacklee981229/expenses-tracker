import 'dart:io';

import 'package:expense_tracker/core/utils/report_brief.dart';
import 'package:expense_tracker/data/services/report_take_store.dart';
import 'package:flutter_test/flutter_test.dart';

ClaudeTake take(String headline) => (
  headline: headline,
  points: [(text: 'Mamak 3 times, RM39.30.', category: 'Food')],
);

void main() {
  late Directory folder;
  late File file;
  late ReportTakeStore store;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('takes');
    file = File('${folder.path}/report_takes.json');
    store = ReportTakeStore(file: () async => file);
  });

  tearDown(() => folder.delete(recursive: true));

  test('the same period, filter and fingerprint finds the take', () async {
    await store.save('2026-11-01|2026-11-30', 'aa', take('Rent led.'));
    final found = await ReportTakeStore(
      file: () async => file,
    ).find('2026-11-01|2026-11-30', 'aa');
    expect(found?.headline, 'Rent led.');
    expect(found?.points.single, (
      text: 'Mamak 3 times, RM39.30.',
      category: 'Food',
    ));
  });

  test('another fingerprint or filter finds nothing', () async {
    await store.save('2026-11-01|2026-11-30', 'aa', take('Rent led.'));
    expect(await store.find('2026-11-01|2026-11-30', 'bb'), isNull);
    expect(await store.find('2026-11-01|2026-11-30|food', 'aa'), isNull);
    expect(await store.find('2026-10-01|2026-10-31', 'aa'), isNull);
  });

  test('a new take for the same period and filter replaces the old', () async {
    await store.save('k', 'aa', take('Old.'));
    await store.save('k', 'bb', take('New.'));
    expect(await store.find('k', 'aa'), isNull);
    expect((await store.find('k', 'bb'))?.headline, 'New.');
  });

  test('keeps the latest 12 periods and filters', () async {
    // Not awaited one by one: saves queue up rather than overwrite.
    await Future.wait([
      for (var i = 0; i < 14; i++) store.save('k$i', 'f', take('Take $i.')),
    ]);
    expect(await store.find('k0', 'f'), isNull);
    expect(await store.find('k1', 'f'), isNull);
    for (var i = 2; i < 14; i++) {
      expect((await store.find('k$i', 'f'))?.headline, 'Take $i.');
    }
  });

  test('a missing or broken file reads as empty', () async {
    expect(await store.find('k', 'f'), isNull);
    for (final broken in ['', '{not json', '{"key": "k"}', '[1, "x"]']) {
      await file.writeAsString(broken);
      expect(await store.find('k', 'f'), isNull);
    }
    // And a save over a broken file still works.
    await store.save('k', 'f', take('Fresh.'));
    expect((await store.find('k', 'f'))?.headline, 'Fresh.');
  });

  test('a failed save does not stop the next one', () async {
    // A file where the folder should be: the save cannot make its folder.
    final blocker = File('${folder.path}/blocker');
    await blocker.writeAsString('x');
    final shaky = ReportTakeStore(
      file: () async => File('${blocker.path}/report_takes.json'),
    );
    await expectLater(
      shaky.save('k', 'f', take('Lost.')),
      throwsA(isA<FileSystemException>()),
    );
    expect(await shaky.find('k', 'f'), isNull);
    await blocker.delete();
    await shaky.save('k', 'f', take('Kept.'));
    expect((await shaky.find('k', 'f'))?.headline, 'Kept.');
  });
}
