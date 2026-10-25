import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/money.dart';

/// Money with the currency in front that counts up from zero when it first
/// appears, then from its old value to the new one whenever it changes. The
/// count runs over whole sen ([IntTween]), so no money passes through a
/// double.
class RollingAmount extends StatelessWidget {
  const RollingAmount(
    this.minor, {
    super.key,
    required this.style,
    this.textAlign,
  });

  final int minor;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: minor),
      duration: AppMotion.page,
      curve: AppMotion.enter,
      builder: (context, value, _) => Text(
        formatWithSymbol(value),
        maxLines: 1,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}
