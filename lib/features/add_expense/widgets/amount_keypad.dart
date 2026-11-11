import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// The numeric keypad:
///
///     1 2 3 +/−
///     4 5 6 Scan
///     7 8 9 Save & Add
///     . 0 ⌫ Save
///
/// Keys stand on a hard shadow and press down onto it like real keys. The
/// scan key (read a screenshot) is tinted with the accent so it reads as a
/// different kind of key.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onDigit,
    required this.onDecimalPoint,
    required this.onPlusMinus,
    required this.onScan,
    required this.onBackspace,
    required this.onSaveAndAdd,
    required this.onSave,
    this.showScan = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimalPoint;
  final VoidCallback onPlusMinus;

  /// Null while editing or while a screenshot is being read.
  final VoidCallback? onScan;
  final VoidCallback onBackspace;

  /// Null while there is nothing valid to save, and when editing.
  final VoidCallback? onSaveAndAdd;

  /// Null while there is nothing valid to save.
  final VoidCallback? onSave;

  /// Whether the scan key is there; a group's entry sheet has no scan, and
  /// leaves its place empty so the other keys stay put.
  final bool showScan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget digit(int value) => _Key(
      onTap: () => onDigit(value.toString()),
      child: _Label(value.toString()),
    );
    Widget row(List<Widget> keys) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SizedBox(
        height: AppSizes.keypadKeyHeight + AppSizes.keyTravel,
        child: Row(
          children: [
            for (final (index, cell) in keys.indexed) ...[
              if (index > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(child: cell),
            ],
          ],
        ),
      ),
    );

    return SafeArea(
      top: false,
      // The keyboard shrinks the bottom padding as it rises; keeping it
      // stops the keypad, and the amount box above it, sinking meanwhile.
      maintainBottomViewPadding: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm + 2,
          AppSpacing.xxs,
          AppSpacing.sm + 2,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row([
              digit(1),
              digit(2),
              digit(3),
              _Key(
                onTap: onPlusMinus,
                child: const _Label(AppStrings.keyPlusMinus, muted: true),
              ),
            ]),
            row([
              digit(4),
              digit(5),
              digit(6),
              if (showScan)
                _Key(
                  onTap: onScan,
                  tinted: true,
                  child: Icon(
                    Icons.document_scanner_rounded,
                    color: colors.accent,
                    semanticLabel: AppStrings.scanScreenshot,
                  ),
                )
              else
                const SizedBox.shrink(),
            ]),
            row([
              digit(7),
              digit(8),
              digit(9),
              _Key(
                onTap: onSaveAndAdd,
                child: Text(
                  AppStrings.saveAndAdd,
                  maxLines: 1,
                  style: AppTextStyles.keypadAction.copyWith(
                    color: colors.accent,
                  ),
                ),
              ),
            ]),
            row([
              _Key(
                onTap: onDecimalPoint,
                child: const _Label(AppStrings.keyDecimal),
              ),
              digit(0),
              _Key(
                onTap: onBackspace,
                child: Icon(
                  Icons.backspace_outlined,
                  color: colors.label,
                  semanticLabel: AppStrings.backspace,
                ),
              ),
              _Key(
                onTap: onSave,
                accent: true,
                child: Text(
                  AppStrings.save,
                  style: AppTextStyles.headline.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// A key on its hard shadow; pressing moves it down onto the shadow.
/// Without [onTap] it is dimmed and ignores taps.
class _Key extends StatefulWidget {
  const _Key({
    required this.onTap,
    required this.child,
    this.accent = false,
    this.tinted = false,
  });

  final VoidCallback? onTap;
  final Widget child;

  /// The violet gradient Save key.
  final bool accent;

  /// A face washed with the accent (the scan key).
  final bool tinted;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _down = false;

  void _setDown(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.onTap != null;
    final shadow = colors.keyShadow;
    return Opacity(
      opacity: enabled ? 1 : AppSizes.disabledOpacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => _setDown(true) : null,
        onTapUp: enabled ? (_) => _setDown(false) : null,
        onTapCancel: enabled ? () => _setDown(false) : null,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: _down ? AppMotion.instant : AppMotion.normal,
            curve: _down ? Curves.easeOut : AppMotion.pop,
            height: AppSizes.keypadKeyHeight,
            // A translate, not a margin: the release spring overshoots
            // past zero, and a negative margin fails Container's assert
            // (a red error box in debug builds).
            transform: Matrix4.translationValues(
              0,
              _down ? AppSizes.keyTravel : 0,
              0,
            ),
            decoration: BoxDecoration(
              color: widget.accent
                  ? colors.primary
                  : widget.tinted
                  ? Color.lerp(colors.keyFace, colors.accent, AppSizes.keyTint)
                  : colors.keyFace,
              borderRadius: BorderRadius.circular(AppRadius.tile),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  offset: Offset(0, _down ? 0 : AppSizes.keyTravel),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            alignment: Alignment.center,
            child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: AppTextStyles.keypadKey.copyWith(
        color: muted ? colors.labelSecondary : colors.label,
      ),
    );
  }
}
