import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'category_avatar.dart';
import 'pressable.dart';

class FloatingTab {
  const FloatingTab({required this.label, required this.icon});

  final String label;

  /// A picture from the icon set.
  final String icon;
}

/// A frosted pill floating above the page, with one tab per item and a
/// darker pill that glides to the selected tab. The selected icon leans and
/// grows a little.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<FloatingTab> tabs;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const inset = AppSizes.tabBarInset;
    final slot = (AppSizes.tabBarWidth - inset * 2) / tabs.length;
    return SizedBox(
      width: AppSizes.tabBarWidth,
      height: AppSizes.tabBarHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              offset: const Offset(0, 18),
              blurRadius: 30,
              spreadRadius: -14,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.tabBar,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: colors.cardEdge),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: AppMotion.page,
                    curve: AppMotion.glide,
                    left: inset + slot * selected,
                    top: inset,
                    bottom: inset,
                    width: slot,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.tile),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.tabIndicator, colors.tabIndicatorEnd],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(inset),
                      child: Row(
                        children: [
                          for (final (index, tab) in tabs.indexed)
                            Expanded(
                              child: _TabButton(
                                tab: tab,
                                selected: index == selected,
                                onTap: () => onSelected(index),
                              ),
                            ),
                        ],
                      ),
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final FloatingTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              turns: selected ? -1 / 30 : 0,
              duration: AppMotion.slow,
              curve: AppMotion.pop,
              child: AnimatedScale(
                scale: selected ? 1.18 : 1,
                duration: AppMotion.slow,
                curve: AppMotion.pop,
                child: UiIcon(tab.icon, size: AppSizes.tabIcon),
              ),
            ),
            const SizedBox(width: AppSpacing.xs - 2),
            AnimatedDefaultTextStyle(
              duration: AppMotion.normal,
              style: AppTextStyles.subheadline.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? colors.onAccent : colors.labelSecondary,
              ),
              child: Text(tab.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
