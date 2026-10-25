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
import '../../../data/database/tables/transactions_table.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/sheets.dart';
import '../../../shared/widgets/swipe_action_row.dart';
import '../../add_expense/add_expense_sheet.dart';
import '../ledger_providers.dart';

/// One line of a receipt: the category icon, the note as the title (the
/// category when there is no note), `time · category` underneath, and the
/// amount as `-RM12.50`. Tap to edit; swipe left for Edit and Delete. A new
/// expense prints in (the row unrolls from nothing); a deleted one is torn
/// away to the right before it goes.
class ExpenseRow extends ConsumerStatefulWidget {
  const ExpenseRow({super.key, required this.item, this.printIn = false});

  final ExpenseWithCategory item;

  /// Whether the row just arrived and should print in.
  final bool printIn;

  @override
  ConsumerState<ExpenseRow> createState() => _ExpenseRowState();
}

class _ExpenseRowState extends ConsumerState<ExpenseRow>
    with TickerProviderStateMixin {
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
    final item = widget.item;
    final expense = item.expense;
    final note = expense.note;
    final category = item.category.name;
    final time = formatTime(
      DateTime.fromMillisecondsSinceEpoch(expense.occurredAt),
    );
    final isRecurring = expense.source == TransactionSource.recurring;

    final row = SwipeActionRow(
      actions: [
        SwipeAction(
          label: AppStrings.edit,
          color: colors.swipeNeutral,
          onPressed: () => showAddExpenseSheet(context, editing: expense),
        ),
        SwipeAction(
          label: AppStrings.delete,
          color: colors.destructive,
          onPressed: _delete,
        ),
      ],
      child: Pressable(
        color: colors.surface,
        pressedScale: 0.97,
        onTap: () => showAddExpenseSheet(context, editing: expense),
        child: Padding(
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
        ),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_print, _tear]),
      child: row,
      builder: (context, child) {
        final printed = AppMotion.enter.transform(_print.value);
        final torn = AppMotion.exit.transform(_tear.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: printed * (1 - torn),
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
    final actions = ref.read(ledgerActionsProvider);
    final confirmed = await confirmDestructive(
      context,
      title: AppStrings.deleteExpenseTitle,
      message: AppStrings.deleteExpenseMessage,
      confirmLabel: AppStrings.deleteExpense,
    );
    if (!confirmed || !mounted) return;
    await _tear.forward();
    await actions.deleteExpense(widget.item.expense.id);
  }
}
