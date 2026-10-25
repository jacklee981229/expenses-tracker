import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  static const int _rowId = 1;

  SimpleSelectStatement<$AppSettingsTable, AppSettingsData> _row() =>
      select(appSettings)..where((s) => s.id.equals(_rowId));

  /// Creates the settings row with its defaults if it is missing.
  Future<void> ensureRow() async {
    await into(appSettings).insert(
      AppSettingsCompanion.insert(id: const Value(_rowId)),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Stream<AppSettingsData> watch() => _row().watchSingle();

  Future<AppSettingsData> get() => _row().getSingle();

  Future<void> setFirstDayOfWeek(int isoWeekday) =>
      _write(AppSettingsCompanion(firstDayOfWeek: Value(isoWeekday)));

  Future<void> setThemeMode(String mode) =>
      _write(AppSettingsCompanion(themeMode: Value(mode)));

  Future<void> setLastExportAt(int epochMs) =>
      _write(AppSettingsCompanion(lastExportAt: Value(epochMs)));

  /// Backup import (replace): the imported settings become the only row.
  Future<void> replaceWith(AppSettingsData settings) async {
    await delete(appSettings).go();
    await into(appSettings).insert(settings.copyWith(id: _rowId));
  }

  Future<void> _write(AppSettingsCompanion values) async {
    await (update(
      appSettings,
    )..where((s) => s.id.equals(_rowId))).write(values);
  }
}
