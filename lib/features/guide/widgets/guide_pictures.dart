import 'package:flutter/material.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/entrance.dart';

/// A guide page's picture: a simple phone screen drawn in the app's own
/// glass, rising from the bottom of a patch of the theme's colours, the
/// thing to tap ringed. Drawn, never real iPhone screenshots: those are
/// Apple's, and the repo is public.
class GuidePicture extends StatelessWidget {
  const GuidePicture({super.key, required this.step});

  /// 0 to 4, the guide's page.
  final int step;

  // Where the four blobs sit (alignment), each spreading this far.
  static const List<(double, double)> _blobPlaces = [
    (-0.9, -0.8),
    (0.95, -0.3),
    (-0.6, 0.9),
    (0.7, 1.0),
  ];
  static const double _blobRadius = 0.9;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gaps = colors.fieldGaps;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // The colour field's blobs, still: a quiet patch of the theme.
          for (final (i, (x, y)) in _blobPlaces.indexed)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(x, y),
                    radius: _blobRadius,
                    colors: [
                      gaps[i].withValues(alpha: colors.fieldAlpha),
                      gaps[i].withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: AppSpacing.xxl,
            bottom: -AppSizes.guidePhoneRadius,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: AppSizes.guidePhoneWidth,
                child: _Phone(
                  child: switch (step) {
                    0 => const _NewShortcut(),
                    1 => const _Actions(),
                    2 => const _FindBackTap(),
                    3 => const _PickDouble(),
                    _ => const _AllowPaste(),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The phone: a glass screen with the island at its top.
class _Phone extends StatelessWidget {
  const _Phone({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: cardDecoration(
        colors,
        radius: AppSizes.guidePhoneRadius,
      ).copyWith(boxShadow: cardShadows(colors)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSizes.guidePhoneIslandWidth,
                height: AppSizes.guidePhoneIslandHeight,
                decoration: BoxDecoration(
                  color: colors.label,
                  borderRadius: BorderRadius.circular(
                    AppSizes.guidePhoneIslandHeight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Page 1: the Shortcuts app's grid of shortcuts, the + ringed.
class _NewShortcut extends StatelessWidget {
  const _NewShortcut();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gaps = colors.fieldGaps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.guideShotShortcuts,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline.copyWith(color: colors.label),
              ),
            ),
            TapRing(
              child: Container(
                width: AppSizes.guideShotIcon + AppSpacing.xxs,
                height: AppSizes.guideShotIcon + AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: AppSizes.guideShotIcon,
                  color: colors.onAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final row in const [
          [0, 1],
          [2, 3],
        ]) ...[
          Row(
            children: [
              for (final (i, gap) in row.indexed) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Entrance(
                    delay: AppMotion.stagger * (gap + 1),
                    child: _ShortcutTile(color: gaps[gap]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

/// A shortcut in the grid: a coloured tile, lighter at the top, with a
/// round glyph and a bar for its name.
class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.color});

  final Color color;

  // The glyph and name bar's white, and the bar's share of the tile.
  static const double _onTile = 0.85;
  static const double _nameWidth = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final light = colors.onAccent;
    return Container(
      height: AppSizes.guideShotTile,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.control),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, light, colors.tint)!, color],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: AppSizes.guideShotGlyph,
            height: AppSizes.guideShotGlyph,
            decoration: BoxDecoration(
              color: light.withValues(alpha: _onTile),
              shape: BoxShape.circle,
            ),
          ),
          FractionallySizedBox(
            widthFactor: _nameWidth,
            child: Container(
              height: AppSizes.guideNameBar,
              decoration: BoxDecoration(
                color: light.withValues(alpha: _onTile),
                borderRadius: BorderRadius.circular(AppSizes.guideNameBar),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A drawn screen's title, as the iPhone shows it above its list.
class _ShotTitle extends StatelessWidget {
  const _ShotTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.headline.copyWith(color: context.colors.label),
      ),
    );
  }
}

/// A row of a drawn screen: a small coloured square, the row's name, and
/// whatever sits at its end. [lit] lifts it out of the rest; [dim] sets it
/// back. Rows come in one after another by [order].
class _ShotRow extends StatelessWidget {
  const _ShotRow({
    required this.label,
    required this.order,
    this.color,
    this.trailing,
    this.lit = false,
    this.dim = false,
    this.below,
    this.level = 0,
  });

  final String label;
  final int order;
  final Color? color;
  final Widget? trailing;
  final bool lit;
  final bool dim;

  /// A second line under the row, inside the same block.
  final Widget? below;

  /// How many screens deep the row is: each level steps in, so rows from
  /// screens you open one inside another don't read as one list.
  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = this.color;
    final trailing = this.trailing;
    final below = this.below;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.guideLevelStep * level,
        bottom: AppSpacing.xs,
      ),
      child: Entrance(
        delay: AppMotion.stagger * (order + 1),
        child: Opacity(
          opacity: dim ? AppSizes.dimOpacity : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.guideShotRow),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: lit ? colors.tile : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: lit ? colors.accent : colors.glassEdge),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (color != null) ...[
                      Container(
                        width: AppSizes.guideShotIcon,
                        height: AppSizes.guideShotIcon,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(
                            AppSizes.guideShotRadius,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption1.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                ?below,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The chevron at the end of a row that opens another screen.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: AppSizes.guideShotIcon,
      color: context.colors.labelTertiary,
    );
  }
}

/// Page 2: the new shortcut's three actions in order, the link in the
/// last.
class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gaps = colors.fieldGaps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ShotTitle(AppStrings.guideShotName),
        _ShotRow(
          order: 0,
          color: gaps[1],
          label: AppStrings.guideShotScreenshot,
        ),
        _ShotRow(
          order: 1,
          color: gaps[2],
          label: AppStrings.guideShotClipboard,
        ),
        _ShotRow(
          order: 2,
          color: gaps[0],
          label: AppStrings.guideShotOpenUrls,
          lit: true,
          below: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xxs,
              bottom: AppSpacing.xxs,
            ),
            child: Text(
              kScanLink,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption1.copyWith(color: colors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// Page 3: Settings › Accessibility › Touch › Back Tap, one row from each
/// screen, the last ringed.
class _FindBackTap extends StatelessWidget {
  const _FindBackTap();

  @override
  Widget build(BuildContext context) {
    final gaps = context.colors.fieldGaps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ShotTitle(AppStrings.settingsTitle),
        _ShotRow(
          order: 0,
          color: gaps[1],
          label: AppStrings.guideShotAccessibility,
          trailing: const _Chevron(),
        ),
        _ShotRow(
          order: 1,
          color: gaps[3],
          label: AppStrings.guideShotTouch,
          level: 1,
          trailing: const _Chevron(),
        ),
        _ShotRow(
          order: 2,
          color: gaps[0],
          label: AppStrings.guideShotBackTap,
          level: 2,
          lit: true,
          trailing: const TapRing(child: _Chevron()),
        ),
      ],
    );
  }
}

/// Page 4: Back Tap's two choices, Double Tap tagged and ringed, then the
/// shortcut picked for it.
class _PickDouble extends StatelessWidget {
  const _PickDouble();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ShotTitle(AppStrings.guideShotBackTap),
        _ShotRow(
          order: 0,
          label: AppStrings.guideShotDouble,
          lit: true,
          trailing: const TapRing(child: _Chevron()),
          below: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                decoration: BoxDecoration(
                  // The deep accent: white on the plain one is too faint in
                  // the dark theme.
                  color: colors.accentDeep,
                  borderRadius: BorderRadius.circular(AppSizes.guideShotRadius),
                ),
                child: Text(
                  AppStrings.guideShotRecommended,
                  style: AppTextStyles.caption2.copyWith(
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),
          ),
        ),
        const _ShotRow(
          order: 1,
          label: AppStrings.guideShotTriple,
          dim: true,
          trailing: _Chevron(),
        ),
        _ShotRow(
          order: 2,
          color: colors.fieldGaps[0],
          label: AppStrings.guideShotName,
          level: 1,
          trailing: Icon(
            Icons.check_rounded,
            size: AppSizes.guideShotIcon,
            color: colors.accent,
          ),
        ),
      ],
    );
  }
}

/// Page 5: the app's paste setting at Allow, then the back of the phone
/// tapped twice.
class _AllowPaste extends StatelessWidget {
  const _AllowPaste();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ShotTitle(AppStrings.appTitle),
        _ShotRow(
          order: 0,
          label: AppStrings.guideShotPaste,
          lit: true,
          below: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Row(
              children: [
                Text(
                  AppStrings.guideShotAllow,
                  style: AppTextStyles.caption1.copyWith(color: colors.accent),
                ),
                const Spacer(),
                Icon(
                  Icons.check_rounded,
                  size: AppSizes.guideShotIcon,
                  color: colors.accent,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: TapRing(
              twice: true,
              child: Icon(
                Icons.touch_app_rounded,
                size: AppSizes.guideTouchIcon,
                color: colors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A soft ring pulsing out from [child], where the finger goes; [twice]
/// sends a second ring just after the first, a double tap. With
/// reduce-motion on it holds still, half grown.
class TapRing extends StatefulWidget {
  const TapRing({super.key, required this.child, this.twice = false});

  final Widget child;
  final bool twice;

  @override
  State<TapRing> createState() => _TapRingState();
}

class _TapRingState extends State<TapRing> with SingleTickerProviderStateMixin {
  // A looping motion, so it takes the scan light's slow loop.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.sweep,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // The second ring of a double tap starts this far into the loop; each
  // ring runs over this share of it; a still ring is half grown, at this
  // opacity; the ring's inside is tinted this much.
  static const double _secondTap = 0.22;
  static const double _ringRun = 0.6;
  static const double _stillOpacity = 0.6;
  static const double _ringFill = 0.12;
  static const double _stillGrow = 0.5;

  Widget _ring(AppColors colors, bool still, double phase) {
    // Each ring grows and fades over the first part of the loop, then
    // waits, so a double tap reads as two quick taps and a rest.
    final t = still
        ? _stillGrow
        : AppMotion.enter.transform(
            ((_pulse.value - phase) / _ringRun).clamp(0, 1),
          );
    return Opacity(
      opacity: still ? _stillOpacity : 1 - t,
      child: Transform.scale(
        scale: still
            ? AppSizes.guideRingStill
            : 1 + (AppSizes.guideRingGrow - 1) * t,
        child: Container(
          width: AppSizes.guideRing,
          height: AppSizes.guideRing,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.accent.withValues(alpha: _ringFill),
            border: Border.all(
              color: colors.accent,
              width: AppSizes.guideRingWidth,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    // The ring overflows the child instead of growing it, so a ringed row
    // keeps its siblings' height.
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: OverflowBox(
              maxWidth: AppSizes.guideRing,
              maxHeight: AppSizes.guideRing,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    _ring(colors, still, 0),
                    if (widget.twice && !still)
                      _ring(colors, still, _secondTap),
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
