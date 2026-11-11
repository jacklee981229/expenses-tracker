import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/hero_surface.dart';
import '../../../shared/widgets/receipt_card.dart';

/// The top of an entry sheet: the grab handle, a close button and the
/// title. Shared by the add sheet and a group's entry sheet.
class EntrySheetHeader extends StatelessWidget {
  const EntrySheetHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm - 2),
        Container(
          width: AppSizes.sheetGrabWidth,
          height: AppSizes.sheetGrabHeight,
          decoration: BoxDecoration(
            color: colors.labelTertiary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSizes.sheetGrabHeight),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: AppSizes.sheetHeaderHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clear of the buttons on both sides; a long notice shrinks.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.navButton + AppSpacing.sm,
                ),
                child: AnimatedSwitcher(
                  duration: AppMotion.normal,
                  child: FittedBox(
                    key: ValueKey(title),
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: AppTextStyles.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.xs,
                child: CircleIconButton(
                  icon: Icons.close_rounded,
                  tooltip: AppStrings.closeSheet,
                  onPressed: () => Navigator.of(context).pop(),
                  background: colors.tile,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The amount box: the amount, then under a dashed line the date pill
/// beside the note field, then [history] (the note chips) when given.
class AmountBox extends StatelessWidget {
  const AmountBox({
    super.key,
    required this.amount,
    required this.date,
    required this.note,
    this.history,
    this.reading = false,
    this.overlay,
    this.categoryColor,
  });

  /// The chosen category's colour, which tints the box.
  final Color? categoryColor;

  /// While a screenshot is read the amount and note blur under the scan
  /// light.
  final bool reading;
  final Widget? overlay;
  final Widget amount;
  final Widget date;
  final Widget note;
  final Widget? history;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onHero;
    final history = this.history;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 2,
        AppSpacing.xs,
        AppSpacing.sm + 2,
        AppSpacing.xxs,
      ),
      child: HeroSurface(
        radius: AppRadius.panel,
        color: switch (categoryColor) {
          final color? => context.colors.box(color),
          null => null,
        },
        overlay: overlay,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md + 2,
          AppSpacing.md,
          AppSpacing.md + 2,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Blurred(blurred: reading, child: amount),
            const SizedBox(height: AppSpacing.xs),
            DashedLine(color: onHero.withValues(alpha: 0.28)),
            const SizedBox(height: AppSpacing.sm - 2),
            Row(
              children: [
                date,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Blurred(blurred: reading, child: note),
                ),
              ],
            ),
            if (history != null) history,
          ],
        ),
      ),
    );
  }
}

/// Blurs and fades [child] while [blurred]: what a screenshot is about to
/// replace.
class _Blurred extends StatelessWidget {
  const _Blurred({required this.blurred, required this.child});

  final bool blurred;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: blurred ? 1 : 0),
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      child: child,
      builder: (context, blur, child) => blur == 0
          ? child!
          : ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: AppSizes.scanBlur * blur,
                sigmaY: AppSizes.scanBlur * blur,
              ),
              child: Opacity(opacity: 1 - blur / 2, child: child),
            ),
    );
  }
}

/// The note field on the amount box.
class EntryNoteField extends StatelessWidget {
  const EntryNoteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onHero = colors.onHero;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onTapOutside: (_) => focusNode.unfocus(),
      maxLines: 1,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: onHero,
      style: AppTextStyles.callout.copyWith(color: onHero),
      decoration: InputDecoration(
        hintText: AppStrings.notePlaceholder,
        hintStyle: AppTextStyles.callout.copyWith(
          color: colors.onHeroSecondary,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      ),
    );
  }
}
