import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../core/utils/money.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/pressable.dart';
import '../ledger_providers.dart';

/// The ledger's category filter, folded into one pill until it is needed.
/// Tapping the pill opens a drawer of glowing category tags (with what each
/// spent this month); picking one narrows the list to it and lights it up,
/// then the drawer folds shut: the other tags fade first and the picked one
/// rises towards the pill, which now shows the category.
class CategoryDrawer extends ConsumerStatefulWidget {
  const CategoryDrawer({super.key});

  @override
  ConsumerState<CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends ConsumerState<CategoryDrawer>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  Timer? _closeTimer;

  /// 0 shut, 1 open. The tags stay built while it folds, so they can leave
  /// gradually instead of vanishing at once.
  late final AnimationController _drawer = AnimationController(
    vsync: this,
    duration: AppMotion.page,
  );

  /// Grows quickly and settles; shutting is the same motion backwards, so
  /// it also lands softly.
  late final Animation<double> _height = CurvedAnimation(
    parent: _drawer,
    curve: AppMotion.enter,
    reverseCurve: AppMotion.enter.flipped,
  );

  /// The tag just picked, which rides the fold up towards the pill.
  String? _picked;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _drawer.dispose();
    super.dispose();
  }

  void _setOpen(bool open) {
    _closeTimer?.cancel();
    setState(() => _open = open);
    if (open) {
      _picked = null;
      _drawer.forward();
    } else {
      _drawer.reverse();
    }
  }

  void _pick(String categoryId) {
    ref.read(ledgerCategoryFilterProvider.notifier).toggle(categoryId);
    _picked = categoryId;
    // Let the picked tag finish lighting up (its pop) before the fold.
    _closeTimer?.cancel();
    _closeTimer = Timer(AppMotion.slow, () {
      if (mounted) _setOpen(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(monthCategoryTotalsProvider);
    final filterId = ref.watch(effectiveLedgerFilterProvider);
    final selected = totals
        .where((total) => total.category.id == filterId)
        .firstOrNull
        ?.category;
    if (totals.isEmpty && filterId == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DrawerPill(
              category: selected,
              open: _open,
              onTap: () => _setOpen(!_open),
            ),
            AnimatedSwitcher(
              duration: AppMotion.normal,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: filterId == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: _ClearButton(
                        onTap: ref
                            .read(ledgerCategoryFilterProvider.notifier)
                            .clear,
                      ),
                    ),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _height,
          builder: (context, _) {
            final open = _drawer.value;
            if (open == 0) return const SizedBox(width: double.infinity);
            return ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                heightFactor: _height.value,
                child: IgnorePointer(
                  ignoring: !_open,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final (index, total) in totals.indexed)
                          _folding(
                            open: _open ? 1 : open,
                            picked: total.category.id == _picked,
                            child: Entrance(
                              key: ValueKey(total.category.id),
                              delay: staggerDelay(index),
                              offset: Offset.zero,
                              fromTilt: -12,
                              fromScale: 0.6,
                              curve: AppMotion.pop,
                              child: _CategoryTag(
                                total: total,
                                tilt: ((index % 3) - 1) * AppSizes.tagTilt,
                                selected: total.category.id == filterId,
                                dimmed:
                                    filterId != null &&
                                    total.category.id != filterId,
                                onTap: () => _pick(total.category.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// How a tag leaves while the drawer shuts ([open] falling to 0): the
/// others fade in the first half, the picked one fades in the second half
/// as it rises towards the pill. While opening it gets 1: the tags have
/// their own entrance.
Widget _folding({
  required double open,
  required bool picked,
  required Widget child,
}) {
  final fade = picked ? open * 2 : (open - 0.5) * 2;
  return Transform.translate(
    offset: Offset(0, picked ? -(1 - open) * AppSpacing.sm : 0),
    child: Opacity(opacity: fade.clamp(0.0, 1.0), child: child),
  );
}

/// "All categories", or the picked category glowing in its colour.
class _DrawerPill extends StatelessWidget {
  const _DrawerPill({
    required this.category,
    required this.open,
    required this.onTap,
  });

  final ExpenseCategory? category;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final category = this.category;
    final tint = category == null
        ? colors.accent
        : colorFromHex(category.colorHex);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: AppMotion.slow,
        curve: AppMotion.enter,
        height: AppSizes.tagHeight + 2,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxs + 2,
          0,
          AppSpacing.sm + 2,
          0,
        ),
        decoration: BoxDecoration(
          color: category == null
              ? colors.navButton
              : Color.lerp(colors.surface, tint, 0.26),
          borderRadius: BorderRadius.circular(AppSizes.tagHeight),
          border: Border.all(color: category == null ? colors.cardEdge : tint),
          boxShadow: [
            if (category != null)
              BoxShadow(
                color: tint.withValues(alpha: 0.7),
                blurRadius: 24,
                spreadRadius: -4,
              )
            else
              BoxShadow(
                color: colors.shadow,
                offset: const Offset(0, 8),
                blurRadius: 16,
                spreadRadius: -10,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.tagIcon + 2,
              height: AppSizes.tagIcon + 2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: AppMotion.normal,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: category == null
                    ? const UiIcon(UiIcons.label, size: AppSizes.inlineIcon)
                    : CategoryIcon(
                        category.iconKey,
                        key: ValueKey(category.id),
                        size: AppSizes.inlineIcon,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              category?.name ?? AppStrings.allCategories,
              style: AppTextStyles.callout.copyWith(color: colors.label),
            ),
            const SizedBox(width: AppSpacing.xxs),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: AppMotion.slow,
              curve: AppMotion.enter,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: AppSizes.inlineIcon,
                color: colors.labelSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: AppStrings.clearCategoryFilter,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.85,
        child: Container(
          width: AppSizes.tagIcon + 2,
          height: AppSizes.tagIcon + 2,
          decoration: BoxDecoration(
            color: colors.navButton,
            shape: BoxShape.circle,
            border: Border.all(color: colors.cardEdge),
          ),
          child: Icon(
            Icons.close_rounded,
            size: AppSizes.labelIcon,
            color: colors.label,
          ),
        ),
      ),
    );
  }
}

/// A tilted tag: icon and amount, the name sliding out when picked, a glow
/// in the category colour around the picked one, the others dimmed.
class _CategoryTag extends StatelessWidget {
  const _CategoryTag({
    required this.total,
    required this.tilt,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final LedgerCategoryTotal total;
  final double tilt;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final category = total.category;
    final tint = colorFromHex(category.colorHex);
    return AnimatedOpacity(
      opacity: dimmed ? AppSizes.dimOpacity : 1,
      duration: AppMotion.normal,
      child: AnimatedRotation(
        turns: (selected ? 0 : tilt) / 360,
        duration: AppMotion.slow,
        curve: AppMotion.pop,
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: AppMotion.slow,
          curve: AppMotion.pop,
          child: Pressable(
            onTap: onTap,
            pressedScale: 0.92,
            child: AnimatedContainer(
              duration: AppMotion.slow,
              curve: AppMotion.enter,
              height: AppSizes.tagHeight,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxs + 1,
                0,
                AppSpacing.sm + 1,
                0,
              ),
              decoration: BoxDecoration(
                color: Color.lerp(colors.surface, tint, selected ? 0.32 : 0.14),
                borderRadius: BorderRadius.circular(AppSizes.tagHeight),
                border: Border.all(
                  color: selected ? tint : tint.withValues(alpha: 0.42),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: tint.withValues(alpha: 0.8),
                          blurRadius: 26,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizes.tagIcon,
                    height: AppSizes.tagIcon,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: CategoryIcon(
                      category.iconKey,
                      size: AppSizes.inlineIcon,
                    ),
                  ),
                  AnimatedSize(
                    duration: AppMotion.slow,
                    curve: AppMotion.enter,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.xs - 1,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppSizes.tagNameMaxWidth,
                              ),
                              child: Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.subheadline.copyWith(
                                  color: colors.label,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: AppSpacing.xs - 1),
                  Text(
                    formatWithSymbol(total.totalMinor),
                    style: AppTextStyles.chipFigure.copyWith(
                      color: colors.label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
