import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money.dart';
import '../../../data/database/daos/transaction_dao.dart';
import '../../../data/database/tables/transactions_table.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/swipe_action_row.dart';
import '../../add_expense/add_expense_sheet.dart';

/// One line of a receipt: the category icon, the note as the title (the
/// category when there is no note), `time · category` underneath, and the
/// amount as `-RM12.50`. Tap to edit; swipe left for Again (a new copy
/// dated today) and Delete. A new expense prints in (the row unrolls from
/// nothing); a deleted one is torn away to the right, leaving its space to
/// the [DeletedExpenseRow] that replaces it.
class ExpenseRow extends StatefulWidget {
  const ExpenseRow({
    super.key,
    required this.item,
    required this.onDelete,
    this.printIn = false,
  });

  final ExpenseWithCategory item;

  /// Called once the row has torn away.
  final ValueChanged<ExpenseWithCategory> onDelete;

  /// Whether the row just arrived and should print in.
  final bool printIn;

  @override
  State<ExpenseRow> createState() => _ExpenseRowState();
}

class _ExpenseRowState extends State<ExpenseRow> with TickerProviderStateMixin {
  late final AnimationController _print = AnimationController(
    vsync: this,
    duration: AppMotion.page,
    value: widget.printIn ? 0 : 1,
  );
  late final AnimationController _tear = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  );

  @override
  void initState() {
    super.initState();
    if (widget.printIn) {
      // Waits for the add sheet to slide away before printing.
      Future<void>.delayed(AppMotion.normal, () {
        if (mounted) _print.forward();
      });
    }
  }

  @override
  void dispose() {
    _print.dispose();
    _tear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final expense = widget.item.expense;

    final row = SwipeActionRow(
      actions: [
        SwipeAction(
          label: AppStrings.again,
          icon: Icons.replay_rounded,
          color: colors.accent,
          onPressed: () => showAddExpenseSheet(context, template: expense),
        ),
        SwipeAction(
          label: AppStrings.delete,
          icon: Icons.delete_outline_rounded,
          color: colors.destructive,
          onPressed: _delete,
        ),
      ],
      child: Pressable(
        color: Colors.transparent,
        pressedScale: 0.97,
        onTap: () => showAddExpenseSheet(context, editing: expense),
        child: _RowContent(widget.item),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_print, _tear]),
      child: row,
      builder: (context, child) {
        final printed = AppMotion.enter.transform(_print.value);
        final torn = AppMotion.exit.transform(_tear.value);
        // Tearing keeps the height: the Undo row takes the same space.
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: printed,
            child: Opacity(
              opacity: (printed * (1 - torn)).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(60 * torn, -12 * (1 - printed)),
                child: Transform.rotate(
                  angle: 4 * torn * math.pi / 180,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete() async {
    await _tear.forward();
    if (mounted) widget.onDelete(widget.item);
  }
}

/// The row's icon, title, detail line and amount.
class _RowContent extends StatelessWidget {
  const _RowContent(this.item);

  final ExpenseWithCategory item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final expense = item.expense;
    final note = expense.note;
    final category = item.category.name;
    final time = formatTime(
      DateTime.fromMillisecondsSinceEpoch(expense.occurredAt),
    );
    final isRecurring = expense.source == TransactionSource.recurring;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 2,
        vertical: AppSpacing.sm - 2,
      ),
      child: Row(
        children: [
          CategoryAvatar.of(item.category),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        note ?? category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.rowTitle.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    if (isRecurring) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      Icon(
                        Icons.repeat_rounded,
                        size: AppSizes.repeatGlyph,
                        color: colors.labelSecondary,
                        semanticLabel: AppStrings.recurringTooltip,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  note == null
                      ? time
                      : AppStrings.timeAndDetail(time, category),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.footnote.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            formatExpense(expense.amountMinor),
            style: AppTextStyles.amount.copyWith(color: colors.label),
          ),
        ],
      ),
    );
  }
}

/// What is left of a deleted expense for a few seconds: a dark bar of the
/// row's height reading `Deleted` and `Undo`; tapping it undoes. It folds
/// away after [kUndoDuration] unless tapped.
class DeletedExpenseRow extends StatefulWidget {
  const DeletedExpenseRow({
    super.key,
    required this.item,
    required this.onUndo,
    required this.onGone,
  });

  final ExpenseWithCategory item;
  final VoidCallback onUndo;

  /// Called once the row has folded away.
  final VoidCallback onGone;

  @override
  State<DeletedExpenseRow> createState() => _DeletedExpenseRowState();
}

class _DeletedExpenseRowState extends State<DeletedExpenseRow>
    with TickerProviderStateMixin {
  late final AnimationController _show = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  );
  late final Timer _timer;
  bool _undone = false;

  @override
  void initState() {
    super.initState();
    _show.forward();
    _timer = Timer(kUndoDuration, _foldAway);
  }

  @override
  void dispose() {
    _timer.cancel();
    _show.dispose();
    _fold.dispose();
    super.dispose();
  }

  Future<void> _foldAway() async {
    await _fold.forward();
    if (mounted) widget.onGone();
  }

  void _undo() {
    if (_undone) return;
    _timer.cancel();
    setState(() => _undone = true);
    widget.onUndo();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: Listenable.merge([_show, _fold]),
      builder: (context, child) {
        final shown = _undone ? 0.0 : AppMotion.pop.transform(_show.value);
        final folded = AppMotion.exit.transform(_fold.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1 - folded,
            child: Stack(
              children: [
                // Invisible, only to keep the deleted row's height.
                Visibility.maintain(
                  visible: false,
                  child: _RowContent(widget.item),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: (shown * (1 - folded)).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * shown,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        child: Semantics(
                          button: true,
                          label: AppStrings.undo,
                          child: Pressable(
                            color: colors.label,
                            borderRadius: BorderRadius.circular(AppRadius.tile),
                            onTap: _undo,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Center(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppStrings.deleted,
                                        style: AppTextStyles.subheadline
                                            .copyWith(color: colors.background),
                                      ),
                                    ),
                                    Text(
                                      AppStrings.undo,
                                      style: AppTextStyles.cardTitle.copyWith(
                                        color: colors.background,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
