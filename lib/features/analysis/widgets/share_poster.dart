import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/insights.dart';
import '../../../core/utils/money.dart';
import '../../../data/database/daos/analysis_dao.dart';
import '../../../data/services/picture_share.dart';
import '../../../shared/today_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/colour_field.dart';
import '../../../shared/widgets/pressable.dart';
import '../analysis_providers.dart';
import 'change_sticker.dart';
import 'glow_ring.dart';
import 'spend_pie_chart.dart';

/// How many categories the shared picture lists.
const int kPosterCategories = 5;

/// The `Share as picture` link at the foot of Analysis: a glass pill.
class SharePictureLink extends StatelessWidget {
  const SharePictureLink({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Pressable(
          pressedScale: 0.94,
          onTap: () => showSharePosterSheet(context),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: cardDecoration(colors, radius: AppSizes.tapTarget / 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.ios_share_rounded,
                  size: AppSizes.bannerIcon,
                  color: colors.changeNew,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppStrings.shareAsPicture,
                  style: AppTextStyles.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the preview of Analysis as a picture: the poster, a Hide amounts
/// switch, and Share, which hands it to the phone's share sheet.
Future<void> showSharePosterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.page,
      reverseDuration: AppMotion.normal,
    ),
    builder: (context) => const _PosterSheet(),
  );
}

class _PosterSheet extends StatefulWidget {
  const _PosterSheet();

  @override
  State<_PosterSheet> createState() => _PosterSheetState();
}

class _PosterSheetState extends State<_PosterSheet> {
  final GlobalKey _picture = GlobalKey();
  bool _hideAmounts = false;
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      await sharePicture(
        _picture.currentContext!.findRenderObject()! as RenderRepaintBoundary,
        fileName: AppStrings.posterFileName,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * AppSizes.reportMaxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            // The theme's drag handle already gives the top its room.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.shareAsPicture,
                    style: AppTextStyles.title2.copyWith(color: colors.label),
                  ),
                ),
                Text(
                  AppStrings.hideAmounts,
                  style: AppTextStyles.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Switch.adaptive(
                  value: _hideAmounts,
                  onChanged: (hide) => setState(() => _hideAmounts = hide),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              // Rounded on screen only: the picture itself keeps its
              // corners, so no chat shows them as black or white.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: RepaintBoundary(
                  key: _picture,
                  child: SharePoster(hideAmounts: _hideAmounts),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            child: FilledButton(
              onPressed: _sharing ? null : _share,
              child: const Text(AppStrings.share),
            ),
          ),
        ],
      ),
    );
  }
}

/// Analysis as one short picture: the period over the month's colour
/// field, its total as the one hero beside a small donut, the top
/// [kPosterCategories] categories with their change stickers, then what it
/// is compared with and the app's name. [hideAmounts] swaps the money for
/// the number of expenses and each category's share, the stickers for
/// percent.
class SharePoster extends ConsumerWidget {
  const SharePoster({super.key, required this.hideAmounts});

  final bool hideAmounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final selection = ref.watch(periodSelectionProvider);
    final bounds = ref.watch(periodBoundsProvider);
    final totals =
        ref.watch(filteredCategoryTotalsProvider).valueOrNull ??
        const <CategoryTotal>[];
    final total = ref.watch(filteredTotalProvider);
    final changes = ref.watch(categoryChangesProvider);
    // The picture always shows the changes, in ringgit as the cards do,
    // or in percent when the amounts are hidden.
    final showChanges = changes != null;
    final percent = hideAmounts;
    final before = sumTotals(
      ref.watch(previousCategoryTotalsProvider).valueOrNull,
    );
    // Every sticker is the spending's change, the hero's too (in percent
    // when the amounts are hidden), as on the cards.
    final heroChange = spendChange(total, before);
    final against = ref.watch(previousPeriodLabelProvider);
    final slices = ref.watch(pieSlicesProvider);
    final sweeps = ringSweeps([for (final slice in slices) slice.totalMinor]);

    final title = switch (selection.period) {
      AnalysisPeriod.week => AppStrings.periodWeek,
      AnalysisPeriod.month => formatMonthName(selection.anchor),
      AnalysisPeriod.year => selection.anchor.year.toString(),
      AnalysisPeriod.all => AppStrings.allTime,
    };
    final days = _days(
      bounds,
      ref.watch(firstExpenseDateProvider).valueOrNull,
      toLocalDateString(ref.watch(todayProvider)),
    );
    final small = AppTextStyles.footnote.copyWith(color: colors.sectionLabel);

    return ColourField(
      spots: ref.watch(analysisFieldProvider),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTextStyles.largeTitle.copyWith(color: colors.label),
            ),
            if (days != null)
              Text(
                AppStrings.reportPeriod(
                  days,
                  ref.watch(categoryFilterProvider).length,
                ),
                style: small,
              ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: cardDecoration(colors),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Swap(
                              hideAmounts
                                  ? AppStrings.expensesStat
                                  : AppStrings.spentStat,
                              style: AppTextStyles.caption1.copyWith(
                                color: colors.labelSecondary,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: _Swap(
                                hideAmounts
                                    ? '${_count(totals)}'
                                    : formatWithSymbol(total),
                                style: AppTextStyles.hero.copyWith(
                                  color: colors.label,
                                ),
                              ),
                            ),
                            if (showChanges && before > 0) ...[
                              const SizedBox(height: AppSizes.tagGap),
                              ChangeSticker(
                                change: heroChange,
                                percent: percent,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox.square(
                        dimension: AppSizes.posterDonut,
                        child: FittedBox(
                          child: SizedBox.square(
                            dimension: _ringBox,
                            child: GlowRing(
                              arcs: ringArcs(
                                slices,
                                sweeps,
                                null,
                                colors.chartOther,
                              ),
                              glow: colors.chartGlow,
                              onTap: (_) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final t in totals.take(kPosterCategories))
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Row(
                        children: [
                          CategoryAvatar.of(
                            t.category,
                            size: AppSizes.smallAvatar,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              t.category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.rowTitle.copyWith(
                                color: colors.label,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _Swap(
                            hideAmounts
                                ? formatShare(
                                    t.totalMinor,
                                    total,
                                    trimZeros: true,
                                  )
                                : formatWithSymbol(t.totalMinor),
                            style: AppTextStyles.amount.copyWith(
                              color: colors.label,
                            ),
                          ),
                          if ((showChanges ? changes[t.category.id] : null)
                              case final change?) ...[
                            const SizedBox(width: AppSpacing.xs),
                            SizedBox(
                              width: AppSizes.tagColumn,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ChangeSticker(
                                  change: change,
                                  percent: percent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (against != null && showChanges)
                  Text(AppStrings.changeVs(against), style: small),
                const Spacer(),
                Text(AppStrings.appTitle, style: small),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The ring as Analysis draws it, its glow included.
  static const double _ringBox =
      (AppSizes.pieCenterRadius + AppSizes.pieRadius + AppSizes.pieGlowBlur) *
      2;

  static int _count(List<CategoryTotal> totals) =>
      totals.fold(0, (sum, t) => sum + t.count);

  /// The days the picture covers, up to today: `1–6 Nov 2026`; All runs
  /// from the first expense. Null before anything is spent under All.
  static String? _days(DateBounds? bounds, String? firstDate, String today) {
    final start = bounds?.start ?? firstDate;
    if (start == null) return null;
    final end = bounds == null
        ? today
        : (bounds.start.compareTo(today) <= 0 &&
              bounds.end.compareTo(today) > 0)
        ? today
        : bounds.end;
    return formatDateRange(start, end);
  }
}

/// [text] that fades across when Hide amounts changes it.
class _Swap extends StatelessWidget {
  const _Swap(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      child: Text(text, key: ValueKey(text), style: style),
    );
  }
}
