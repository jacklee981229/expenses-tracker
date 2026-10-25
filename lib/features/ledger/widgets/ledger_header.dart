import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../shared/today_provider.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/large_title.dart';
import '../../../shared/widgets/pill_chip.dart';
import '../../../shared/widgets/sheets.dart';
import '../../settings/settings_screen.dart';
import '../ledger_providers.dart';
import 'category_drawer.dart';
import 'export_nudge_banner.dart';
import 'total_card.dart';

/// The top of the ledger: the month as the page title (tap it to pick
/// another), month arrows and settings, the total card, and the category
/// drawer. It scrolls with the list below it.
class LedgerHeader extends ConsumerWidget {
  const LedgerHeader({super.key, required this.forward});

  /// Which way the month last moved, so its title slides the same way.
  final bool forward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final months = ref.read(selectedMonthProvider.notifier);
    final today = ref.watch(todayProvider);
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeTitle(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _pickMonth(context, month, months),
            child: AnimatedSwitcher(
              duration: AppMotion.slow,
              switchInCurve: AppMotion.enter,
              switchOutCurve: AppMotion.exit,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, if (current != null) current],
              ),
              transitionBuilder: (child, animation) {
                final incoming = child.key == ValueKey(month);
                final from = Offset((incoming == forward) ? 0.25 : -0.25, 0);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: from,
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(formatMonthShort(month), key: ValueKey(month)),
            ),
          ),
          kicker: AppStrings.ledgerKicker,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: AppStrings.previous,
                onPressed: months.previous,
              ),
              CircleIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: AppStrings.next,
                onPressed: months.next,
              ),
              CircleIconButton(
                asset: UiIcons.gear,
                tooltip: AppStrings.settingsTooltip,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.enter,
          alignment: Alignment.topLeft,
          child: isCurrentMonth
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PillChip(
                      label: AppStrings.thisMonth,
                      selected: false,
                      onTap: () => months.select(today),
                    ),
                  ),
                ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md + 2),
          child: TotalCard(),
        ),
        const SizedBox(height: AppSpacing.xl),
        const ExportNudgeBanner(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: CategoryDrawer(),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  Future<void> _pickMonth(
    BuildContext context,
    DateTime month,
    SelectedMonthNotifier months,
  ) async {
    final picked = await showDatePickerSheet(
      context,
      initial: month,
      mode: CupertinoDatePickerMode.monthYear,
    );
    if (picked != null) months.select(picked);
  }
}
