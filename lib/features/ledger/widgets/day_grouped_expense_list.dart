import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money.dart';
import '../../../data/database/daos/transaction_dao.dart';
import '../../../shared/today_provider.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/receipt_card.dart';
import '../ledger_providers.dart';
import 'expense_row.dart';

/// Where receipts come in from when they first appear.
enum EnterFrom { below, left, right }

/// Expenses as one paper receipt per day, newest day first: a stamp with
/// the date on top, a row per expense, and the day's total at the torn
/// bottom. Receipts lean a little, alternating sides, and come in one after
/// another. An expense added to a day already on screen prints into its
/// receipt, which gives a small wobble. A deleted expense leaves an Undo row
/// in its place for a few seconds. [header] scrolls in above the days;
/// [empty] shows under it when there are none. Shared by the ledger and the
/// analysis category drilldown.
class DayGroupedExpenseList extends ConsumerStatefulWidget {
  const DayGroupedExpenseList({
    super.key,
    required this.groups,
    this.header,
    this.empty,
    this.scope = '',
    this.enterFrom = EnterFrom.below,
  });

  final List<DayGroup> groups;
  final Widget? header;
  final Widget? empty;

  /// Changing it treats every receipt as new, so they all come in again,
  /// e.g. the month or the category filter.
  final String scope;
  final EnterFrom enterFrom;

  @override
  ConsumerState<DayGroupedExpenseList> createState() =>
      _DayGroupedExpenseListState();
}

class _DayGroupedExpenseListState extends ConsumerState<DayGroupedExpenseList> {
  final Set<String> _seenDays = {};
  final Set<String> _seenRows = {};

  /// When the current [DayGroupedExpenseList.scope] began: receipts built
  /// soon after come in staggered, later ones (scrolled to) without delay.
  String? _scope;
  DateTime _scopeStart = DateTime.now();

  /// Deleted expenses still offering Undo, by id. Each shows as an Undo row
  /// once its expense has left [DayGroupedExpenseList.groups].
  final Map<String, ExpenseWithCategory> _deleted = {};

  /// Ids whose Undo was pressed: their Undo rows go when the expense is back.
  final Set<String> _undone = {};

  void _delete(ExpenseWithCategory item) {
    setState(() => _deleted[item.expense.id] = item);
    ref.read(ledgerActionsProvider).deleteExpense(item.expense.id);
  }

  void _undo(ExpenseWithCategory item) {
    _undone.add(item.expense.id);
    ref.read(ledgerActionsProvider).restoreExpense(item.expense);
  }

  void _gone(ExpenseWithCategory item) {
    setState(() => _deleted.remove(item.expense.id));
  }

  /// [groups] plus an empty receipt for each day whose last expense was just
  /// deleted, so its Undo row has somewhere to stay.
  List<DayGroup> _withDeletedDays(List<DayGroup> groups, Set<String> live) {
    final days = {for (final group in groups) group.localDate};
    final missing = {
      for (final item in _deleted.values)
        if (!live.contains(item.expense.id) &&
            !days.contains(item.expense.localDate))
          item.expense.localDate,
    };
    if (missing.isEmpty) return groups;
    return [
      ...groups,
      for (final day in missing) DayGroup(localDate: day, items: const []),
    ]..sort((a, b) => b.localDate.compareTo(a.localDate));
  }

  @override
  Widget build(BuildContext context) {
    final header = widget.header;
    final empty = widget.empty;
    final today = ref.watch(todayProvider);
    if (_scope != widget.scope) {
      _scope = widget.scope;
      _scopeStart = DateTime.now();
      _deleted.clear();
      _undone.clear();
    }
    final live = {
      for (final group in widget.groups)
        for (final item in group.items) item.expense.id,
    };
    // An undone expense is back in the list: its Undo row has done its job.
    for (final id in _undone.where(live.contains).toList()) {
      _deleted.remove(id);
      _undone.remove(id);
    }
    final groups = _withDeletedDays(widget.groups, live);
    final lead = header == null ? 0 : 1;
    final showEmpty = groups.isEmpty && empty != null;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSizes.fabClearance),
      itemCount: lead + (showEmpty ? 1 : groups.length),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return _KeepAlive(child: header);
        if (showEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: empty,
          );
        }
        final position = index - lead;
        final group = groups[position];
        final dayKey = '${widget.scope}|${group.localDate}';
        // Rows only print in when their receipt was already on screen; a
        // whole new receipt comes in by itself instead.
        final dayIsNew = _seenDays.add(dayKey);
        final staggered =
            dayIsNew &&
            DateTime.now().difference(_scopeStart) < AppMotion.page * 2;
        final printing = <String>{
          for (final item in group.items)
            if (_seenRows.add(item.expense.id) && !dayIsNew) item.expense.id,
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md + 2,
            AppSpacing.sm,
            AppSpacing.md + 2,
            AppSpacing.sm,
          ),
          child: Entrance(
            key: ValueKey(dayKey),
            animate: dayIsNew,
            delay: staggered ? staggerDelay(position) : Duration.zero,
            offset: switch (widget.enterFrom) {
              EnterFrom.below => const Offset(0, 24),
              EnterFrom.left => const Offset(-48, 0),
              EnterFrom.right => const Offset(48, 0),
            },
            fromTilt: switch (widget.enterFrom) {
              EnterFrom.below => -2,
              EnterFrom.left => -3,
              EnterFrom.right => 3,
            },
            child: _DayReceipt(
              group: group,
              tilt: position.isEven
                  ? -AppSizes.receiptTilt
                  : AppSizes.receiptTilt,
              isToday: dateOnly(group.date) == dateOnly(today),
              printing: printing,
              deleted: [
                for (final item in _deleted.values)
                  if (item.expense.localDate == group.localDate &&
                      !live.contains(item.expense.id))
                    item,
              ],
              onDelete: _delete,
              onUndo: _undo,
              onGone: _gone,
            ),
          ),
        );
      },
    );
  }
}

/// Keeps the list header mounted when it scrolls out of view, so the total
/// card does not swing in again on the way back up.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// One day's receipt. It wobbles whenever an expense prints into it.
class _DayReceipt extends StatefulWidget {
  const _DayReceipt({
    required this.group,
    required this.tilt,
    required this.isToday,
    required this.printing,
    required this.deleted,
    required this.onDelete,
    required this.onUndo,
    required this.onGone,
  });

  final DayGroup group;
  final double tilt;
  final bool isToday;

  /// Ids of rows that just arrived and print in.
  final Set<String> printing;

  /// This day's deleted expenses still offering Undo.
  final List<ExpenseWithCategory> deleted;
  final ValueChanged<ExpenseWithCategory> onDelete;
  final ValueChanged<ExpenseWithCategory> onUndo;
  final ValueChanged<ExpenseWithCategory> onGone;

  @override
  State<_DayReceipt> createState() => _DayReceiptState();
}

class _DayReceiptState extends State<_DayReceipt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: AppMotion.page,
  );

  @override
  void initState() {
    super.initState();
    if (widget.printing.isNotEmpty) _wobble.forward(from: 0);
  }

  @override
  void didUpdateWidget(_DayReceipt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.printing.isNotEmpty) _wobble.forward(from: 0);
  }

  @override
  void dispose() {
    _wobble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final group = widget.group;
    // Undo rows sit where their expense was, newest first like the rest.
    final rows =
        [
          for (final item in group.items) (item: item, deleted: false),
          for (final item in widget.deleted) (item: item, deleted: true),
        ]..sort(
          (a, b) =>
              b.item.expense.occurredAt.compareTo(a.item.expense.occurredAt),
        );
    return AnimatedBuilder(
      animation: _wobble,
      builder: (context, child) {
        // Swings left, back past centre, and settles: degrees over time.
        final t = _wobble.value;
        final swing = t == 0 || t == 1
            ? 0.0
            : math.sin(t * math.pi * 2.5) * (1 - t) * 6;
        return Transform.rotate(
          angle: swing * math.pi / 180,
          child: Transform.scale(scale: 1 + (1 - t) * t * 0.08, child: child),
        );
      },
      child: ReceiptCard(
        tilt: widget.tilt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md + 2,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formatReceiptStamp(group.date),
                      style: AppTextStyles.stamp.copyWith(
                        color: colors.sectionLabel,
                      ),
                    ),
                  ),
                  if (widget.isToday) const _TodayBadge(),
                ],
              ),
            ),
            for (final (index, row) in rows.indexed) ...[
              if (index > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                  child: DashedLine(),
                ),
              if (row.deleted)
                DeletedExpenseRow(
                  key: ValueKey('deleted-${row.item.expense.id}'),
                  item: row.item,
                  onUndo: () => widget.onUndo(row.item),
                  onGone: () => widget.onGone(row.item),
                )
              else
                ExpenseRow(
                  key: ValueKey(row.item.expense.id),
                  item: row.item,
                  printIn: widget.printing.contains(row.item.expense.id),
                  onDelete: widget.onDelete,
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md + 2,
                AppSpacing.xxs,
                AppSpacing.md + 2,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  const DashedLine(thickness: 2),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.receiptTotal,
                          style: AppTextStyles.stamp.copyWith(
                            color: colors.sectionLabel,
                          ),
                        ),
                      ),
                      Text(
                        formatWithSymbol(group.totalMinor),
                        style: AppTextStyles.receiptTotal.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayBadge extends StatelessWidget {
  const _TodayBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Transform.rotate(
      angle: 4 * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs - 1,
          vertical: AppSpacing.xxs - 1,
        ),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(AppSpacing.xs - 1),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.8),
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Text(
          AppStrings.todayBadge,
          style: AppTextStyles.caption2.copyWith(
            color: colors.onAccent,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
