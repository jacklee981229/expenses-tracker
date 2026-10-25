import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/utils/icon_registry.dart';
import '../../shared/widgets/empty_state.dart';
import '../add_expense/add_expense_sheet.dart';
import 'ledger_providers.dart';
import 'widgets/day_grouped_expense_list.dart';
import 'widgets/ledger_header.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  /// Which way the receipts last came in: from below when the ledger opens
  /// or the category changes, from the side the month moved towards.
  EnterFrom _enterFrom = EnterFrom.below;

  /// Which way the month last moved, for the title.
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedMonthProvider, (previous, next) {
      if (previous == null || previous == next) return;
      setState(() {
        _forward = next.isAfter(previous);
        _enterFrom = _forward ? EnterFrom.right : EnterFrom.left;
      });
    });
    ref.listen(effectiveLedgerFilterProvider, (previous, next) {
      if (previous != next) setState(() => _enterFrom = EnterFrom.below);
    });
    final groups = ref.watch(monthDayGroupsProvider);
    final month = ref.watch(selectedMonthProvider);
    final filter = ref.watch(effectiveLedgerFilterProvider);
    final header = LedgerHeader(forward: _forward);

    return SafeArea(
      bottom: false,
      child: groups.when(
        data: (groups) => DayGroupedExpenseList(
          groups: groups,
          header: header,
          // A new month or category replays the receipts' entrance.
          scope: '${month.toIso8601String()}|$filter',
          enterFrom: _enterFrom,
          empty: EmptyState(
            icon: UiIcons.receipt,
            message: AppStrings.noExpensesThisMonth,
            actionLabel: AppStrings.addExpense,
            onAction: () => showAddExpenseSheet(context),
          ),
        ),
        loading: () => header,
        error: (error, _) =>
            EmptyState(icon: UiIcons.receipt, message: error.toString()),
      ),
    );
  }
}
