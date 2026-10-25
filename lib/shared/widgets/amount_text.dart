import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/utils/money.dart';

/// A right-aligned amount in tabular figures, so columns of numbers line up.
class AmountText extends StatelessWidget {
  const AmountText(
    this.minor, {
    super.key,
    this.style = AppTextStyles.amount,
    this.color,
    this.withSymbol = false,
  });

  final int minor;
  final TextStyle style;
  final Color? color;
  final bool withSymbol;

  @override
  Widget build(BuildContext context) {
    return Text(
      withSymbol ? formatWithSymbol(minor) : formatMinor(minor),
      textAlign: TextAlign.right,
      maxLines: 1,
      style: style.copyWith(
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
