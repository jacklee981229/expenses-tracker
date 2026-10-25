import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/amount_input.dart';
import '../../../core/utils/money.dart';

/// The amount as it is typed, in big white figures on the amount box,
/// reading `RM0.00` while empty. It gives a small bump on every key, and
/// after Save & Add the next blank amount drops in from above. While the
/// expression has an operator, its total shows on the right.
class AmountDisplay extends StatefulWidget {
  const AmountDisplay({
    super.key,
    required this.expression,
    required this.resultMinor,
    required this.showResult,
    this.sent = 0,
  });

  final String expression;
  final int? resultMinor;
  final bool showResult;

  /// Goes up by one on each Save & Add.
  final int sent;

  @override
  State<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<AmountDisplay>
    with TickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: AppMotion.quick,
    value: 1,
  );
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: AppMotion.page,
    value: 1,
  );

  @override
  void didUpdateWidget(AmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sent != oldWidget.sent) {
      _drop.forward(from: 0);
    } else if (widget.expression != oldWidget.expression) {
      _bump.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bump.dispose();
    _drop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onAccent;
    final result = widget.resultMinor;
    final expression = widget.expression;
    final typed = expression.isEmpty
        ? formatMinor(0)
        : displayExpression(expression);

    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([_bump, _drop]),
            builder: (context, child) {
              final bump =
                  1 + 0.06 * (1 - Curves.easeOut.transform(_bump.value));
              final drop = AppMotion.enter.transform(_drop.value);
              return Opacity(
                opacity: _drop.value,
                child: Transform.translate(
                  offset: Offset(0, -26 * (1 - drop)),
                  child: Transform.scale(
                    scale: bump,
                    alignment: Alignment.centerLeft,
                    child: child,
                  ),
                ),
              );
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.withCurrency(typed),
                maxLines: 1,
                style: AppTextStyles.amountEntry.copyWith(color: onHero),
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: AppMotion.normal,
          child: widget.showResult && result != null
              ? Padding(
                  key: const ValueKey('result'),
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Text(
                    AppStrings.expressionResult(formatMinor(result)),
                    style: AppTextStyles.chipFigure.copyWith(
                      color: onHero.withValues(alpha: 0.8),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
