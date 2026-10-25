import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/database/tables/app_settings_table.dart';
import '../../data/services/import_service.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/inset_row.dart';
import '../../shared/widgets/sheets.dart';
import '../../shared/widgets/glow_scaffold.dart';
import '../categories/manage_categories_screen.dart';
import '../recurring/recurring_list_screen.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final firstDayOfWeek = settings?.firstDayOfWeek ?? DateTime.monday;
    final themeMode = settings?.themeMode ?? ThemeModeSetting.system;
    final lastExportAt = settings?.lastExportAt;

    return GlowScaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          InsetGroup(
            header: AppStrings.sectionData,
            children: [
              InsetRow(
                title: AppStrings.manageCategories,
                showChevron: true,
                onTap: () => _push(context, const ManageCategoriesScreen()),
              ),
              InsetRow(
                title: AppStrings.fixedMonthlyExpenses,
                showChevron: true,
                onTap: () => _push(context, const RecurringListScreen()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          InsetGroup(
            header: AppStrings.sectionPreferences,
            children: [
              InsetRow(
                title: AppStrings.appearance,
                trailing: _Value(
                  _appearanceLabels[themeMode] ?? AppStrings.appearanceSystem,
                ),
                showChevron: true,
                onTap: () => _pickAppearance(context, ref, themeMode),
              ),
              InsetRow(
                title: AppStrings.firstDayOfWeek,
                trailing: _Value(AppStrings.weekdays[firstDayOfWeek - 1]),
                showChevron: true,
                onTap: () => _pickFirstDay(context, ref, firstDayOfWeek),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          InsetGroup(
            header: AppStrings.sectionBackup,
            footer: lastExportAt == null
                ? AppStrings.lastExportNever
                : AppStrings.lastExport(
                    formatShortDate(
                      DateTime.fromMillisecondsSinceEpoch(lastExportAt),
                    ),
                  ),
            children: [
              InsetRow(
                title: AppStrings.exportCsv,
                titleColor: colors.accent,
                onTap: () => _export(context, ref, json: false),
              ),
              InsetRow(
                title: AppStrings.exportJson,
                titleColor: colors.accent,
                onTap: () => _export(context, ref, json: true),
              ),
              InsetRow(
                title: AppStrings.importJson,
                titleColor: colors.accent,
                onTap: () => _import(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const InsetGroup(
            header: AppStrings.sectionAbout,
            children: [
              InsetRow(
                title: AppStrings.version,
                trailing: _Value(kAppVersion),
              ),
              InsetRow(
                title: AppStrings.build,
                trailing: _Value(kAppBuildNumber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  static const Map<String, String> _appearanceLabels = {
    ThemeModeSetting.system: AppStrings.appearanceSystem,
    ThemeModeSetting.light: AppStrings.appearanceLight,
    ThemeModeSetting.dark: AppStrings.appearanceDark,
  };

  Future<void> _pickAppearance(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final actions = ref.read(settingsActionsProvider);
    final mode = await showOptionsSheet<String>(
      context,
      title: AppStrings.appearance,
      options: [
        for (final MapEntry(key: mode, value: label)
            in _appearanceLabels.entries)
          SheetOption(label, mode, selected: mode == current),
      ],
    );
    if (mode != null) await actions.setThemeMode(mode);
  }

  Future<void> _pickFirstDay(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final actions = ref.read(settingsActionsProvider);
    final day = await showOptionsSheet<int>(
      context,
      title: AppStrings.firstDayOfWeek,
      options: [
        for (final (index, name) in AppStrings.weekdays.indexed)
          SheetOption(name, index + 1, selected: index + 1 == current),
      ],
    );
    if (day != null) await actions.setFirstDayOfWeek(day);
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref, {
    required bool json,
  }) async {
    final actions = ref.read(backupActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final done = json
          ? await actions.exportJson()
          : await actions.exportCsv();
      if (done) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.exported)),
        );
      }
    } on Object catch (error) {
      if (context.mounted) {
        await showAlert(
          context,
          title: AppStrings.exportFailedTitle,
          message: error.toString(),
        );
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(backupActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final BackupData? data;
    try {
      data = await actions.pickBackup();
    } on UnsupportedBackupVersionException catch (error) {
      if (context.mounted) {
        await _importFailed(
          context,
          AppStrings.importUnsupportedVersion(error.version),
        );
      }
      return;
    } on InvalidBackupException {
      if (context.mounted) {
        await _importFailed(context, AppStrings.importInvalidFile);
      }
      return;
    }
    if (data == null || !context.mounted) return;

    final mode = await showOptionsSheet<ImportMode>(
      context,
      title: AppStrings.importTitle,
      message: AppStrings.importSummary(
        data.categories.length,
        data.recurringRules.length,
        data.transactions.length,
      ),
      options: const [
        SheetOption(AppStrings.importMerge, ImportMode.merge),
        SheetOption(
          AppStrings.importReplace,
          ImportMode.replace,
          destructive: true,
        ),
      ],
    );
    if (mode == null) return;
    try {
      await actions.restore(data, mode);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.importDone(data.transactions.length)),
        ),
      );
    } on Object {
      // Rolled back: an id clash or an expense whose category is missing.
      if (context.mounted) {
        await _importFailed(context, AppStrings.importInvalidFile);
      }
    }
  }

  Future<void> _importFailed(BuildContext context, String reason) {
    return showAlert(
      context,
      title: AppStrings.importFailedTitle,
      message: AppStrings.importFailure(reason),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: context.colors.labelSecondary),
    );
  }
}
