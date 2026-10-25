import 'package:drift/drift.dart';

abstract final class ThemeModeSetting {
  static const String system = 'system';
  static const String light = 'light';
  static const String dark = 'dark';
}

/// A single row with `id = 1`.
@DataClassName('AppSettingsData')
class AppSettings extends Table {
  IntColumn get id => integer()();

  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  IntColumn get firstDayOfWeek => integer().withDefault(const Constant(1))();

  /// Appearance: one of [ThemeModeSetting].
  TextColumn get themeMode =>
      text().withDefault(const Constant(ThemeModeSetting.system))();

  /// Epoch milliseconds of the last successful export.
  IntColumn get lastExportAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
