import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/data_providers.dart';
import '../../data/database/tables/app_settings_table.dart';
import '../../data/services/cloud_backup.dart';
import '../../data/services/cloud_backup_api.dart';
import '../../data/services/import_service.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/inset_row.dart';
import '../../shared/widgets/sheets.dart';
import '../../shared/widgets/large_title.dart';
import '../categories/manage_categories_screen.dart';
import '../ledger/ledger_providers.dart';
import '../recurring/recurring_list_screen.dart';
import 'settings_providers.dart';

/// The Settings tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final firstDayOfWeek = settings?.firstDayOfWeek ?? DateTime.monday;
    final themeMode = settings?.themeMode ?? ThemeModeSetting.system;
    final lastExportAt = settings?.lastExportAt;
    final claudeKey = ref.watch(claudeKeyProvider).valueOrNull;
    final cloud = ref.watch(cloudBackupStatusProvider).valueOrNull;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(
          bottom: AppSizes.fabClearance + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const LargeTitle(Text(AppStrings.settingsTitle)),
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
            header: AppStrings.sectionClaude,
            footer: AppStrings.claudeFooter,
            children: [
              InsetRow(
                title: AppStrings.claudeKey,
                trailing: _Value(
                  claudeKey == null
                      ? AppStrings.claudeKeyNotSet
                      : AppStrings.claudeKeyEnding(claudeKey),
                ),
                showChevron: true,
                onTap: () => _editClaudeKey(context, ref, claudeKey),
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
                title: AppStrings.cloudBackup,
                trailing: _Value(_cloudValue(cloud)),
                showChevron: true,
                onTap: cloud == null
                    ? null
                    : () => _cloudBackup(context, ref, cloud),
              ),
              InsetRow(
                title: AppStrings.exportCsv,
                titleColor: colors.accent,
                onTap: () => _export(context, ref, backup: false),
              ),
              InsetRow(
                title: AppStrings.exportBackup,
                titleColor: colors.accent,
                onTap: () => _export(context, ref, backup: true),
              ),
              InsetRow(
                title: AppStrings.importBackup,
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

  /// Adds a key, or for a set one offers to replace or remove it.
  Future<void> _editClaudeKey(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final store = ref.read(claudeKeyStoreProvider);
    if (current != null) {
      final remove = await showOptionsSheet<bool>(
        context,
        title: AppStrings.claudeKey,
        options: const [
          SheetOption(AppStrings.claudeKeyReplace, false),
          SheetOption(AppStrings.claudeKeyRemove, true, destructive: true),
        ],
      );
      if (remove == null) return;
      if (remove) {
        await store.delete();
        ref.invalidate(claudeKeyProvider);
        return;
      }
      if (!context.mounted) return;
    }
    final key = await showTextInputDialog(
      context,
      title: AppStrings.claudeKey,
      message: AppStrings.claudeKeyMessage,
      placeholder: AppStrings.claudeKeyPlaceholder,
    );
    if (key == null) return;
    await store.write(key);
    ref.invalidate(claudeKeyProvider);
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
    required bool backup,
  }) async {
    final actions = ref.read(backupActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final done = backup
          ? await actions.exportBackup()
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
    final data = await _readBackup(
      context,
      ref.read(backupActionsProvider).pickBackup,
    );
    if (data == null || !context.mounted) return;
    await _chooseAndRestore(context, ref, data);
  }

  /// Runs [read]; null when it gives nothing or, after saying why, for a
  /// file that is not a backup this app reads.
  Future<BackupData?> _readBackup(
    BuildContext context,
    Future<BackupData?> Function() read,
  ) async {
    try {
      return await read();
    } on UnsupportedBackupVersionException catch (error) {
      if (context.mounted) {
        await _importFailed(
          context,
          AppStrings.importUnsupportedVersion(error.version),
        );
      }
    } on InvalidBackupException {
      if (context.mounted) {
        await _importFailed(context, AppStrings.importInvalidFile);
      }
    }
    return null;
  }

  /// Asks Merge or Replace, then restores; [afterRestore] runs once it is
  /// done.
  Future<void> _chooseAndRestore(
    BuildContext context,
    WidgetRef ref,
    BackupData data, {
    Future<void> Function()? afterRestore,
  }) async {
    final actions = ref.read(backupActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final mode = await showOptionsSheet<ImportMode>(
      context,
      title: AppStrings.importTitle,
      message: AppStrings.importSummary(
        data.categories.length,
        data.recurringRules.length,
        data.transactions.length,
        data.splits.groups.length,
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
      await afterRestore?.call();
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

  static String _cloudValue(CloudBackupStatus? status) {
    if (status == null) return '';
    if (!status.hasToken) return AppStrings.cloudBackupOff;
    if (!status.state.setUp) return AppStrings.cloudBackupNotSetUp;
    final lastGoodAt = status.state.lastGoodAt;
    if (lastGoodAt == null) return AppStrings.cloudBackupOn;
    final at = DateTime.fromMillisecondsSinceEpoch(lastGoodAt);
    return '${formatDayMonth(at)}, ${formatTime(at)}';
  }

  /// Off: asks for the token. Otherwise the choices for this phone.
  Future<void> _cloudBackup(
    BuildContext context,
    WidgetRef ref,
    CloudBackupStatus status,
  ) async {
    if (!status.hasToken) return _cloudTurnOn(context, ref, ask: true);
    final choice = await showOptionsSheet<_CloudChoice>(
      context,
      title: AppStrings.cloudBackup,
      options: [
        if (status.state.setUp)
          const SheetOption(AppStrings.backUpNow, _CloudChoice.backUpNow),
        const SheetOption(AppStrings.restoreFromCloud, _CloudChoice.restore),
        if (!status.state.setUp)
          const SheetOption(AppStrings.cloudTurnOn, _CloudChoice.turnOn),
        const SheetOption(
          AppStrings.cloudTurnOff,
          _CloudChoice.turnOff,
          destructive: true,
        ),
      ],
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case _CloudChoice.backUpNow:
        await _cloudBackUpNow(context, ref);
      case _CloudChoice.restore:
        await _cloudRestore(context, ref);
      case _CloudChoice.turnOn:
        await _cloudTurnOn(context, ref, ask: false);
      case _CloudChoice.turnOff:
        await ref.read(cloudBackupProvider).turnOff();
        ref.invalidate(cloudBackupStatusProvider);
    }
  }

  /// Checks the token (typed when [ask], else the one kept from an earlier
  /// install) and sets this phone up. An empty phone, a new install, is
  /// offered the cloud's copies at once, before anything of its own goes up.
  Future<void> _cloudTurnOn(
    BuildContext context,
    WidgetRef ref, {
    required bool ask,
  }) async {
    String? typed;
    if (ask) {
      typed = await showTextInputDialog(
        context,
        title: AppStrings.cloudBackup,
        message: AppStrings.cloudTokenMessage,
        placeholder: AppStrings.cloudTokenPlaceholder,
      );
      if (typed == null) return;
    }
    final result = await ref.read(cloudBackupProvider).turnOn(typed);
    ref.invalidate(cloudBackupStatusProvider);
    if (!context.mounted) return;
    final listing = result.value;
    if (listing == null) return _cloudFailed(context, result.failure!);
    final expenses = await ref.read(expenseCountProvider.future);
    if (expenses == 0 && listing.restorable.isNotEmpty && context.mounted) {
      await _cloudRestoreFrom(context, ref, listing);
    }
  }

  Future<void> _cloudBackUpNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(cloudBackupProvider).uploadNow();
    ref.invalidate(cloudBackupStatusProvider);
    final uploaded = result.value;
    if (uploaded == null) {
      if (context.mounted) await _cloudFailed(context, result.failure!);
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          uploaded ? AppStrings.backedUp : AppStrings.nothingToBackUp,
        ),
      ),
    );
  }

  Future<void> _cloudRestore(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(cloudBackupProvider).list();
    if (!context.mounted) return;
    final listing = result.value;
    if (listing == null) return _cloudFailed(context, result.failure!);
    if (listing.restorable.isEmpty) {
      return showAlert(
        context,
        title: AppStrings.restoreFromCloud,
        message: AppStrings.cloudNoCopies,
      );
    }
    await _cloudRestoreFrom(context, ref, listing);
  }

  /// Picks a kept day, fetches it and restores it as Import does; this
  /// phone is then set up.
  Future<void> _cloudRestoreFrom(
    BuildContext context,
    WidgetRef ref,
    CloudListing listing,
  ) async {
    final copy = await showOptionsSheet<CloudCopy>(
      context,
      title: AppStrings.restoreFromCloud,
      message: AppStrings.cloudCopiesLag,
      options: [
        for (final copy in listing.restorable)
          SheetOption(
            AppStrings.cloudCopy(
              formatWeekdayDayMonth(parseLocalDate(copy.day)),
              copy.count,
            ),
            copy,
          ),
      ],
    );
    if (copy == null || !context.mounted) return;
    final cloud = ref.read(cloudBackupProvider);
    CloudFailure? failure;
    final data = await _readBackup(context, () async {
      final fetched = await cloud.fetch(listing, copy);
      failure = fetched.failure;
      return fetched.value;
    });
    if (!context.mounted) return;
    final reason = failure;
    if (reason != null) return _cloudFailed(context, reason);
    if (data == null) return;
    await _chooseAndRestore(
      context,
      ref,
      data,
      afterRestore: () async {
        await cloud.markSetUp();
        ref.invalidate(cloudBackupStatusProvider);
      },
    );
  }

  Future<void> _cloudFailed(BuildContext context, CloudFailure failure) {
    return showAlert(
      context,
      title: AppStrings.cloudFailedTitle,
      message: switch (failure) {
        CloudFailure.wrongToken => AppStrings.cloudWrongToken,
        CloudFailure.noConnection => AppStrings.cloudNoConnection,
        CloudFailure.noAnswer => AppStrings.cloudNoAnswer,
      },
    );
  }

  Future<void> _importFailed(BuildContext context, String reason) {
    return showAlert(
      context,
      title: AppStrings.importFailedTitle,
      message: AppStrings.importFailure(reason),
    );
  }
}

enum _CloudChoice { backUpNow, restore, turnOn, turnOff }

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
