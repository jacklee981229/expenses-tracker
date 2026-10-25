import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/settings_dao.dart';
import '../../data/database/tables/app_settings_table.dart';
import '../../data/services/export_service.dart';
import '../../data/services/import_service.dart';
import '../../data/services/recurring_generator.dart';

final settingsProvider = StreamProvider<AppSettingsData>(
  (ref) => ref.watch(settingsDaoProvider).watch(),
);

/// ISO weekday the week starts on (1 = Monday).
final firstDayOfWeekProvider = Provider<int>(
  (ref) =>
      ref.watch(settingsProvider).valueOrNull?.firstDayOfWeek ??
      DateTime.monday,
);

/// Light, dark, or following the phone.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(settingsProvider).valueOrNull?.themeMode;
  return switch (mode) {
    ThemeModeSetting.light => ThemeMode.light,
    ThemeModeSetting.dark => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

final settingsActionsProvider = Provider<SettingsActions>(
  (ref) => SettingsActions(ref.watch(settingsDaoProvider)),
);

class SettingsActions {
  const SettingsActions(this._dao);

  final SettingsDao _dao;

  Future<void> setFirstDayOfWeek(int isoWeekday) =>
      _dao.setFirstDayOfWeek(isoWeekday);

  /// One of [ThemeModeSetting].
  Future<void> setThemeMode(String mode) => _dao.setThemeMode(mode);
}

final backupActionsProvider = Provider<BackupActions>(
  (ref) => BackupActions(
    exporter: ref.watch(exportServiceProvider),
    importer: ref.watch(importServiceProvider),
    settings: ref.watch(settingsDaoProvider),
    generator: ref.watch(recurringGeneratorProvider),
  ),
);

class BackupActions {
  const BackupActions({
    required ExportService exporter,
    required ImportService importer,
    required SettingsDao settings,
    required RecurringGenerator generator,
  }) : _exporter = exporter,
       _importer = importer,
       _settings = settings,
       _generator = generator;

  final ExportService _exporter;
  final ImportService _importer;
  final SettingsDao _settings;
  final RecurringGenerator _generator;

  /// Writes the file and opens the share sheet. Returns whether the export
  /// counts as done (the sheet was not dismissed), which is then recorded.
  Future<bool> exportCsv() async => _share(await _exporter.writeCsvFile());

  Future<bool> exportJson() async => _share(await _exporter.writeJsonFile());

  Future<bool> _share(File file) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
    if (result.status == ShareResultStatus.dismissed) return false;
    await _settings.setLastExportAt(DateTime.now().millisecondsSinceEpoch);
    return true;
  }

  /// Lets the user pick a JSON backup and validates it; null if they
  /// cancel. Throws [InvalidBackupException] or
  /// [UnsupportedBackupVersionException] for a bad file.
  Future<BackupData?> pickBackup() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final file = result?.files.singleOrNull;
    if (file == null) return null;
    final bytes = file.bytes;
    final path = file.path;
    final String text;
    if (bytes != null) {
      text = utf8.decode(bytes);
    } else if (path != null) {
      text = await File(path).readAsString();
    } else {
      throw const InvalidBackupException();
    }
    return _importer.parse(text);
  }

  /// Imports all-or-nothing, then generates any fixed expenses now due.
  Future<void> restore(BackupData data, ImportMode mode) async {
    await _importer.apply(data, mode);
    await _generator.catchUp();
  }
}
