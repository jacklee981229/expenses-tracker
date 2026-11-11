import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/icon_registry.dart';
import '../../core/utils/money.dart';
import '../../data/database/app_database.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/circle_icon_button.dart';
import '../../shared/widgets/colour_field.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/floating_add_button.dart';
import '../../shared/widgets/large_title.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/receipt_card.dart';
import '../../shared/widgets/sheets.dart';
import 'group_sheets.dart';
import 'split_entry_sheet.dart';
import 'split_providers.dart';
import 'widgets/settle_up.dart';
import 'widgets/split_entry_row.dart';

/// A group's own page over its own colours: its name, days, people and
/// spending, a Settle up button that opens who pays whom, then its days
/// as receipts, and its own + button.
class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  /// Deleted entries still offering Undo, by id.
  final Map<String, SplitItem> _deleted = {};

  /// Ids whose Undo was pressed: their Undo rows go when the entry is back.
  final Set<String> _undone = {};

  /// The group and its summary as last shown.
  SplitGroup? _group;
  SplitSummary? _summary;

  void _delete(SplitItem item) {
    setState(() => _deleted[item.entry.id] = item);
    ref.read(splitActionsProvider).deleteEntry(item.entry.id);
  }

  Future<void> _undo(SplitItem item) async {
    _undone.add(item.entry.id);
    try {
      await ref.read(splitActionsProvider).restoreEntry(item.saved);
    } on Exception {
      // Someone on it was removed meanwhile: the entry can't come back, so
      // its Undo row goes rather than staying as a gap.
      if (mounted) {
        setState(() {
          _undone.remove(item.entry.id);
          _deleted.remove(item.entry.id);
        });
      }
    }
  }

  void _add() => showSplitEntrySheet(context, groupId: widget.groupId);

  Future<void> _menu(SplitGroup group) async {
    final action = await showOptionsSheet<_GroupAction>(
      context,
      title: group.name,
      options: [
        const SheetOption(AppStrings.renameGroup, _GroupAction.rename),
        const SheetOption(AppStrings.people, _GroupAction.people),
        SheetOption(
          group.isArchived ? AppStrings.restore : AppStrings.archive,
          _GroupAction.archive,
        ),
        const SheetOption(
          AppStrings.deleteGroup,
          _GroupAction.delete,
          destructive: true,
        ),
      ],
    );
    if (action == null || !mounted) return;
    final actions = ref.read(splitActionsProvider);
    switch (action) {
      case _GroupAction.rename:
        final name = await showTextInputDialog(
          context,
          title: AppStrings.renameGroup,
          placeholder: group.name,
        );
        if (name != null) await actions.renameGroup(group.id, name);
      case _GroupAction.people:
        await showPeopleSheet(context, group.id);
      case _GroupAction.archive:
        await actions.setArchived(group.id, archived: !group.isArchived);
      case _GroupAction.delete:
        final confirmed = await confirmDestructive(
          context,
          title: AppStrings.deleteGroupTitle(group.name),
          message: AppStrings.deleteGroupMessage,
          confirmLabel: AppStrings.deleteGroup,
        );
        if (!confirmed || !mounted) return;
        Navigator.of(context).pop();
        await actions.deleteGroup(group.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // A deleted group keeps showing as it was while its page slides away.
    final live = ref.watch(splitGroupProvider(widget.groupId));
    final group = _group = live ?? _group;
    // Once deleted, the rows going don't empty the page either.
    final data = _summary = live == null
        ? _summary
        : ref.watch(splitSummaryProvider(widget.groupId)).valueOrNull ??
              _summary;
    if (group == null) return const SizedBox.shrink();

    return ColourField(
      spots: data?.field ?? const [],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            CircleIconButton(
              icon: Icons.more_horiz_rounded,
              tooltip: AppStrings.groupMenu,
              onPressed: () => _menu(group),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        body: Stack(
          children: [
            if (data != null) _list(group, data),
            Positioned(
              right: AppSpacing.lg,
              bottom: AppSizes.tabBarBottom,
              child: SafeArea(
                top: false,
                child: FloatingAddButton(
                  tooltip: AppStrings.addExpense,
                  onPressed: _add,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(SplitGroup group, SplitSummary summary) {
    final live = {
      for (final day in summary.days)
        for (final item in day.items) item.entry.id,
    };
    // An undone entry is back in the list: its Undo row has done its job.
    for (final id in _undone.where(live.contains).toList()) {
      _deleted.remove(id);
      _undone.remove(id);
    }
    final gone = [
      for (final item in _deleted.values)
        if (!live.contains(item.entry.id)) item,
    ];
    final days = <String>{
      for (final day in summary.days) day.localDate,
      for (final item in gone) item.entry.localDate,
    }.toList()..sort((a, b) => b.compareTo(a));
    final header = _Header(group: group, summary: summary);

    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: AppSizes.fabClearance + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: 1 + (days.isEmpty ? 1 : days.length),
      itemBuilder: (context, index) {
        if (index == 0) return header;
        if (days.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: EmptyState(
              icon: UiIcons.receipt,
              message: AppStrings.noGroupExpenses,
              actionLabel: AppStrings.addExpense,
              onAction: _add,
            ),
          );
        }
        final position = index - 1;
        final localDate = days[position];
        final day = summary.days
            .where((d) => d.localDate == localDate)
            .firstOrNull;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md + 2,
            AppSpacing.xs,
            AppSpacing.md + 2,
            AppSpacing.xs,
          ),
          child: _DayReceipt(
            localDate: localDate,
            totalMinor: day?.totalMinor ?? 0,
            tilt: position.isEven
                ? -AppSizes.receiptTilt
                : AppSizes.receiptTilt,
            rows: [
              // Undo rows sit where their entry was, newest first like
              // the rest.
              for (final (:item, :deleted) in [
                for (final item in day?.items ?? const <SplitItem>[])
                  (item: item, deleted: false),
                for (final item in gone)
                  if (item.entry.localDate == localDate)
                    (item: item, deleted: true),
              ]..sort(_newestFirst))
                if (deleted)
                  DeletedSplitRow(
                    key: ValueKey('deleted-${item.entry.id}'),
                    item: item,
                    summary: summary,
                    onUndo: () => _undo(item),
                    onGone: () =>
                        setState(() => _deleted.remove(item.entry.id)),
                  )
                else
                  SplitEntryRow(
                    key: ValueKey(item.entry.id),
                    item: item,
                    summary: summary,
                    onTap: () => showSplitEntrySheet(
                      context,
                      groupId: widget.groupId,
                      editing: item,
                    ),
                    onDelete: () => _delete(item),
                  ),
            ],
          ),
        );
      },
    );
  }
}

enum _GroupAction { rename, people, archive, delete }

/// The order the group's entries come in from the database.
int _newestFirst(
  ({SplitItem item, bool deleted}) a,
  ({SplitItem item, bool deleted}) b,
) {
  final byTime = b.item.entry.occurredAt.compareTo(a.item.entry.occurredAt);
  return byTime != 0
      ? byTime
      : b.item.entry.createdAt.compareTo(a.item.entry.createdAt);
}

/// The group's name, its days, people and spending, and Settle up.
class _Header extends StatelessWidget {
  const _Header({required this.group, required this.summary});

  final SplitGroup group;
  final SplitSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeTitle(Text(group.name), bottomGap: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            AppStrings.groupSpent(
              summary.dayRange,
              summary.people.length,
              formatWithSymbol(summary.totalMinor),
            ),
            style: AppTextStyles.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
        ),
        if (summary.entryCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + 2,
              0,
              AppSpacing.md + 2,
              AppSpacing.xs,
            ),
            child: _SettleButton(onTap: () => showSettleSheet(context, group)),
          ),
      ],
    );
  }
}

/// Settle up: a glass bar that opens who pays whom.
class _SettleButton extends StatelessWidget {
  const _SettleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: Pressable(
        pressedScale: 0.97,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.settleButton),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: cardDecoration(colors, radius: AppRadius.tile),
          child: Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: AppSizes.bannerIcon,
                color: colors.changeNew,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  AppStrings.settleUp,
                  style: AppTextStyles.headline.copyWith(color: colors.label),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.labelTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// One day of the group as a receipt: the stamp and the day's total, then
/// its rows with dashes between.
class _DayReceipt extends StatelessWidget {
  const _DayReceipt({
    required this.localDate,
    required this.totalMinor,
    required this.tilt,
    required this.rows,
  });

  final String localDate;
  final int totalMinor;
  final double tilt;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ReceiptCard(
      tilt: tilt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + 2,
              AppSpacing.sm,
              AppSpacing.md - 2,
              AppSpacing.xxs - 2,
            ),
            child: Row(
              children: [
                Text(
                  formatReceiptStamp(parseLocalDate(localDate)),
                  style: AppTextStyles.stamp.copyWith(
                    color: colors.sectionLabel,
                  ),
                ),
                const Spacer(),
                Text(
                  formatWithSymbol(totalMinor),
                  style: AppTextStyles.stampFigure.copyWith(
                    color: colors.sectionLabel,
                  ),
                ),
              ],
            ),
          ),
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: DashedLine(),
              ),
            row,
          ],
          const SizedBox(height: AppSpacing.xxs),
        ],
      ),
    );
  }
}
