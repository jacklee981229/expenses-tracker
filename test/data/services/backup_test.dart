import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/services/export_service.dart';
import 'package:expense_tracker/data/services/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Two installs: each seeds the default categories with its own random ids.
  late AppDatabase backupPhone;
  late AppDatabase phone;
  setUp(() {
    backupPhone = AppDatabase(NativeDatabase.memory());
    phone = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await backupPhone.close();
    await phone.close();
  });

  Future<ExpenseCategory> named(AppDatabase db, String name) async =>
      (await db.categoryDao.getAll()).firstWhere((c) => c.name == name);

  Future<String> spend(
    AppDatabase db,
    String category, {
    int cents = 1250,
  }) async => db.transactionDao.insertExpense(
    amountMinor: cents,
    categoryId: (await named(db, category)).id,
    occurredAt: DateTime(2026, 11, 5, 12),
    note: 'Lunch',
  );

  Future<List<int>> exportFrom(AppDatabase db) =>
      ExportService(db, clock: () => DateTime(2026, 11, 5)).buildBackupBytes();

  Future<void> importInto(AppDatabase db, List<int> bytes, ImportMode mode) {
    final importer = ImportService(db);
    return importer.apply(importer.parse(bytes), mode);
  }

  group('file format', () {
    test('the backup is gzip and comes back whole', () async {
      await spend(backupPhone, 'Food');
      final bytes = await exportFrom(backupPhone);
      expect(bytes.take(2), [0x1f, 0x8b]);

      await importInto(phone, bytes, ImportMode.replace);
      final expenses = await phone.transactionDao.getAll();
      expect(expenses, hasLength(1));
      expect(expenses.single.amountMinor, 1250);
      expect(
        await phone.categoryDao.getAll(),
        await backupPhone.categoryDao.getAll(),
      );
    });

    test('an old plain JSON backup still imports', () async {
      await spend(backupPhone, 'Food');
      final json = await ExportService(backupPhone).buildJson();
      final bytes = utf8.encode(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      final data = ImportService(phone).parse(bytes);
      expect(data.transactions, hasLength(1));
    });

    test('a file that is not a backup is refused', () {
      final importer = ImportService(phone);
      final notBackups = <List<int>>[
        [0xff, 0xfe, 0x00, 0xd8, 0x00, 0xdc], // not UTF-8
        [0x1f, 0x8b, 0x08, 0x00, 0x01, 0x02], // a broken gzip
        gzip.encode(utf8.encode('not json')),
        utf8.encode('{"version": 1}'),
        utf8.encode('[1, 2]'),
        const [],
      ];
      for (final bytes in notBackups) {
        expect(
          () => importer.parse(bytes),
          throwsA(isA<InvalidBackupException>()),
          reason: '$bytes',
        );
      }
    });

    test('another version is named', () {
      expect(
        () => ImportService(phone).parse(utf8.encode('{"version": 99}')),
        throwsA(isA<UnsupportedBackupVersionException>()),
      );
    });
  });

  group('merge', () {
    test('same names with other ids join the phone categories', () async {
      await spend(backupPhone, 'Food');
      await spend(phone, 'Food', cents: 500);
      final before = await phone.categoryDao.getAll();

      await importInto(phone, await exportFrom(backupPhone), ImportMode.merge);

      expect(await phone.categoryDao.getAll(), before);
      final food = await named(phone, 'Food');
      final expenses = await phone.transactionDao.getAll();
      expect(expenses, hasLength(2));
      expect(expenses.map((e) => e.categoryId), everyElement(food.id));
    });

    test('names match ignoring case and extra spaces', () async {
      final food = await named(backupPhone, 'Food');
      await backupPhone.categoryDao.updateCategory(
        id: food.id,
        name: '  FOOD ',
        iconKey: food.iconKey,
        colorHex: food.colorHex,
      );
      await spend(backupPhone, '  FOOD ');

      await importInto(phone, await exportFrom(backupPhone), ImportMode.merge);

      expect(
        (await phone.transactionDao.getAll()).single.categoryId,
        (await named(phone, 'Food')).id,
      );
    });

    test('fixed expenses move to the matched category', () async {
      await backupPhone.recurringDao.insertRule(
        amountMinor: 150000,
        categoryId: (await named(backupPhone, 'Food')).id,
        note: 'Rent',
        dayOfMonth: 1,
        startMonth: '2026-12',
        endMonth: null,
        isActive: true,
      );

      await importInto(phone, await exportFrom(backupPhone), ImportMode.merge);

      expect(
        (await phone.recurringDao.getAll()).single.categoryId,
        (await named(phone, 'Food')).id,
      );
    });

    test('an archived match is used when it is the only one', () async {
      final food = await named(phone, 'Food');
      await phone.categoryDao.archive(food.id);
      await spend(backupPhone, 'Food');

      await importInto(phone, await exportFrom(backupPhone), ImportMode.merge);

      expect((await phone.transactionDao.getAll()).single.categoryId, food.id);
      expect(
        (await phone.categoryDao.getAll()).where((c) => c.name == 'Food'),
        hasLength(1),
      );
    });

    test(
      'with doubles on the phone, the active one, then the oldest',
      () async {
        final seeded = await named(phone, 'Food');
        await phone.categoryDao.archive(seeded.id);
        final first = await phone.categoryDao.insertCategory(
          name: 'Food',
          iconKey: seeded.iconKey,
          colorHex: seeded.colorHex,
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await phone.categoryDao.insertCategory(
          name: 'food',
          iconKey: seeded.iconKey,
          colorHex: seeded.colorHex,
        );
        await spend(backupPhone, 'Food');

        await importInto(
          phone,
          await exportFrom(backupPhone),
          ImportMode.merge,
        );

        expect((await phone.transactionDao.getAll()).single.categoryId, first);
      },
    );

    test('a new name is added after the phone categories', () async {
      await backupPhone.categoryDao.insertCategory(
        name: 'Pets',
        iconKey: 'food',
        colorHex: '336699',
      );
      await spend(backupPhone, 'Pets');
      final before = await phone.categoryDao.getAll();

      await importInto(phone, await exportFrom(backupPhone), ImportMode.merge);

      final after = await phone.categoryDao.getAll();
      expect(after, hasLength(before.length + 1));
      expect(after.take(before.length), before);
      expect(after.last.name, 'Pets');
      expect(
        (await phone.transactionDao.getAll()).single.categoryId,
        after.last.id,
      );
    });

    test('merging the same backup twice adds nothing more', () async {
      await spend(backupPhone, 'Food');
      final bytes = await exportFrom(backupPhone);
      await importInto(phone, bytes, ImportMode.merge);
      final categories = await phone.categoryDao.getAll();

      await importInto(phone, bytes, ImportMode.merge);

      expect(await phone.categoryDao.getAll(), categories);
      expect(await phone.transactionDao.getAll(), hasLength(1));
    });
  });
}
