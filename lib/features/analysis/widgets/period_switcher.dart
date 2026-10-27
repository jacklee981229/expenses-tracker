import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../analysis_providers.dart';
import 'category_filter_sheet.dart';

/// Week / Month / Year / All as a frosted bar with a violet pill that
/// glides to the chosen period, the filter button beside it, then the
/// period navigator (hidden for All).
class PeriodSwitcher extends ConsumerWidget {
  const PeriodSwitcher({super.key});

  static const Map<AnalysisPeriod, String> _labels = {
    AnalysisPeriod.week: AppStrings.periodWeek,
    AnalysisPeriod.month: AppStrings.periodMonth,
    AnalysisPeriod.year: AppStrings.periodYear,
    AnalysisPeriod.all: AppStrings.periodAll,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final selection = ref.watch(periodSelectionProvider);
    final periods = ref.read(periodSelectionProvider.notifier);
    final bounds = ref.watch(periodBoundsProvider);
    final filtering = ref.watch(categoryFilterProvider).isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Segments(
                  labels: _labels.values.toList(),
                  selected: AnalysisPeriod.values.indexOf(selection.period),
                  onSelected: (index) =>
                      periods.setPeriod(AnalysisPeriod.values[index]),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              CircleIconButton(
                icon: Icons.filter_alt_rounded,
                tooltip: AppStrings.filter,
                background: filtering ? colors.accent : null,
                foreground: filtering ? colors.onAccent : null,
                onPressed: () => showCategoryFilterSheet(context),
              ),
            ],
          ),
          AnimatedSize(
            duration: AppMotion.slow,
            curve: AppMotion.enter,
            child: selection.period == AnalysisPeriod.all
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      children: [
                        CircleIconButton(
                          icon: Icons.chevron_left_rounded,
                          tooltip: AppStrings.previous,
                          size: AppSizes.periodArrow,
                          onPressed: periods.previous,
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: AppMotion.normal,
                            child: Text(
                              periodLabel(selection, bounds),
                              key: ValueKey(periodLabel(selection, bounds)),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.callout.copyWith(
                                color: colors.label,
                              ),
                            ),
                          ),
                        ),
                        CircleIconButton(
                          icon: Icons.chevron_right_rounded,
                          tooltip: AppStrings.next,
                          size: AppSizes.periodArrow,
                          onPressed: periods.next,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A row of equal segments over a pill that glides to the selected one.
class _Segments extends StatelessWidget {
  const _Segments({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const inset = AppSizes.segmentInset;
    return Container(
      height: AppSizes.segmentHeight + inset * 2,
      decoration: BoxDecoration(
        color: colors.navButton,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        border: Border.all(color: colors.glassEdge),
      ),
      padding: const EdgeInsets.all(inset),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppMotion.page,
                curve: AppMotion.glide,
                left: slot * selected,
                top: 0,
                bottom: 0,
                width: slot,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.control + 1),
                    // The same pill as the tab bar's.
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colors.tabIndicator, colors.tabIndicatorEnd],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (index, label) in labels.indexed)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: index == selected,
                        child: Pressable(
                          onTap: () => onSelected(index),
                          pressedScale: 0.92,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: AppMotion.normal,
                              style: AppTextStyles.callout.copyWith(
                                color: index == selected
                                    ? colors.label
                                    : colors.labelSecondary,
                              ),
                              child: Text(label),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
