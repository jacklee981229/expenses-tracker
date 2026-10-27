import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/sheets.dart';

/// The expense date as a frosted pill on the amount box: `Today`,
/// `Yesterday`, or `09/22 Tue`. Tapping it opens a date wheel with Today and
/// Yesterday as one-tap shortcuts.
class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.today,
    required this.onChanged,
  });

  /// Local midnight of the chosen day.
  final DateTime date;
  final DateTime today;
  final ValueChanged<DateTime> onChanged;

  DateTime get _yesterday => DateTime(today.year, today.month, today.day - 1);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onHero = colors.onHero;
    final label = date == today
        ? AppStrings.today
        : date == _yesterday
        ? AppStrings.yesterday
        : formatChipDate(date, today);

    return Semantics(
      button: true,
      label: AppStrings.chooseDate,
      child: Pressable(
        onTap: () => _pick(context),
        pressedScale: 0.92,
        child: Container(
          height: AppSizes.inlineChipHeight,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            0,
            AppSpacing.sm - 2,
            0,
          ),
          decoration: BoxDecoration(
            color: colors.heroChip,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const UiIcon(UiIcons.calendar, size: AppSizes.labelIcon),
              const SizedBox(width: AppSpacing.xxs + 2),
              AnimatedSwitcher(
                duration: AppMotion.normal,
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: AppTextStyles.subheadline.copyWith(color: onHero),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePickerSheet(
      context,
      initial: date,
      shortcuts: [
        (AppStrings.today, today),
        (AppStrings.yesterday, _yesterday),
      ],
    );
    if (picked != null) onChanged(dateOnly(picked));
  }
}
