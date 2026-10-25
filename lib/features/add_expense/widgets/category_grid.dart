import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';

/// The category picker: every active category as a tile with its 3D icon,
/// four to a row, scrolling when there are many, then a + tile that adds a
/// category. The picked tile fills with its colour, leans and grows a
/// little, and its icon pops.
class CategoryGrid extends StatefulWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.onAddCategory,
  });

  /// Active (non-archived) categories in display order.
  final List<ExpenseCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onAddCategory;

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  static const int _columns = AppSizes.categoryGridColumns;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.sm + 2,
    AppSpacing.xxs,
    AppSpacing.sm + 2,
    AppSpacing.xs,
  );

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  @override
  void didUpdateWidget(CategoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) _revealSelected();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Scrolls the selected category's row into view once laid out, e.g. when
  /// editing an expense whose category is far down a long grid.
  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final index = widget.categories.indexWhere(
        (c) => c.id == widget.selectedId,
      );
      if (index < 0) return;
      final position = _scroll.position;
      final top =
          _padding.top +
          (index ~/ _columns) * (AppSizes.gridCellHeight + AppSpacing.xs);
      final bottom = top + AppSizes.gridCellHeight;
      final double target;
      if (top < position.pixels) {
        target = top;
      } else if (bottom > position.pixels + position.viewportDimension) {
        target = bottom - position.viewportDimension;
      } else {
        return;
      }
      _scroll.animateTo(
        target.clamp(0.0, position.maxScrollExtent),
        duration: AppMotion.slow,
        curve: AppMotion.enter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    return GridView.builder(
      controller: _scroll,
      padding: _padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisExtent: AppSizes.gridCellHeight,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return _Tile(
            label: AppStrings.newCategoryCell,
            icon: const Opacity(
              opacity: 0.55,
              child: UiIcon(UiIcons.plus, size: AppSizes.gridIcon),
            ),
            tint: null,
            selected: false,
            onTap: widget.onAddCategory,
          );
        }
        final category = categories[index];
        return _Tile(
          label: category.name,
          icon: CategoryIcon(category.iconKey, size: AppSizes.gridIcon),
          tint: colorFromHex(category.colorHex),
          selected: category.id == widget.selectedId,
          onTap: () => widget.onSelected(category.id),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final Color? tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = this.tint ?? colors.accent;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedRotation(
        turns: (selected ? AppSizes.tileTilt : 0) / 360,
        duration: AppMotion.slow,
        curve: AppMotion.pop,
        child: AnimatedScale(
          scale: selected ? AppSizes.tileScale : 1,
          duration: AppMotion.slow,
          curve: AppMotion.pop,
          child: Pressable(
            onTap: onTap,
            pressedScale: 0.9,
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.enter,
              decoration: BoxDecoration(
                color: selected
                    ? Color.lerp(colors.tile, tint, 0.24)
                    : colors.tile,
                borderRadius: BorderRadius.circular(AppRadius.tile),
                border: Border.all(
                  color: selected
                      ? tint.withValues(alpha: 0.5)
                      : colors.tileBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.tileBorder,
                    offset: const Offset(0, 2),
                  ),
                  if (selected)
                    BoxShadow(
                      color: tint.withValues(alpha: 0.6),
                      offset: const Offset(0, 12),
                      blurRadius: 18,
                      spreadRadius: -10,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PopOnSelect(selected: selected, child: icon),
                  const SizedBox(height: AppSpacing.xxs + 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption1.copyWith(
                        color: selected ? colors.label : colors.labelSecondary,
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

/// Pops [child] from small and twisted to full size on a bouncy spring each
/// time [selected] turns on.
class _PopOnSelect extends StatefulWidget {
  const _PopOnSelect({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  State<_PopOnSelect> createState() => _PopOnSelectState();
}

class _PopOnSelectState extends State<_PopOnSelect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  @override
  void didUpdateWidget(_PopOnSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _pop.animateWith(SpringSimulation(AppSprings.check, 0.6, 1, 0));
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pop,
      child: widget.child,
      builder: (context, child) => Transform.rotate(
        angle: (1 - _pop.value) * -50 * math.pi / 180,
        child: Transform.scale(scale: _pop.value, child: child),
      ),
    );
  }
}
