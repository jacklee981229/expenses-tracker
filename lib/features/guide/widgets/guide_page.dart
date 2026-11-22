import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'guide_pictures.dart';

/// One page: its picture on top, then the title and its line, or its
/// numbered steps when it has several (page 2, whose link and Copy button
/// sit under the second step).
class GuidePage extends StatelessWidget {
  const GuidePage({
    super.key,
    required this.index,
    required this.title,
    required this.lines,
  });

  final int index;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final numbered = lines.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppSizes.guidePictureHeight,
          child: GuidePicture(step: index),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title3.copyWith(color: colors.label),
                ),
                for (final (i, line) in lines.indexed) ...[
                  SizedBox(height: i == 0 ? AppSpacing.xs : AppSpacing.sm),
                  if (numbered)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StepNumber(i + 1),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: _Line(line)),
                      ],
                    )
                  else
                    _Line(line),
                  if (index == 1 && i == 1)
                    const Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.xs,
                        left: AppSizes.guideStepNumber + AppSpacing.sm,
                      ),
                      child: _LinkRow(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A line of the guide, its `**marked**` names in bold and full colour.
class _Line extends StatelessWidget {
  const _Line(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = AppTextStyles.body.copyWith(color: colors.labelSecondary);
    final strong = AppTextStyles.callout.copyWith(
      color: colors.label,
      fontSize: base.fontSize,
    );
    // Between each pair of markers is a name: every odd piece.
    final pieces = text.split('**');
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final (i, piece) in pieces.indexed)
            TextSpan(text: piece, style: i.isOdd ? strong : null),
        ],
      ),
    );
  }
}

/// A step's number in a small round tint, level with the line's first row.
class _StepNumber extends StatelessWidget {
  const _StepNumber(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AppSizes.guideStepNumber,
      height: AppSizes.guideStepNumber,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.fill, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: AppTextStyles.caption1.copyWith(color: colors.label),
      ),
    );
  }
}

/// The scan link to paste into Open URLs, and a Copy button that says
/// Copied for a moment after.
class _LinkRow extends StatefulWidget {
  const _LinkRow();

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _copied = false;

  // Counts taps, so only the last tap's timer turns Copied back.
  int _taps = 0;

  Future<void> _copy() async {
    final tap = ++_taps;
    await Clipboard.setData(const ClipboardData(text: kScanLink));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(kScanNoticeDuration);
    if (mounted && tap == _taps) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              kScanLink,
              maxLines: 1,
              style: AppTextStyles.callout.copyWith(color: colors.label),
            ),
          ),
          TextButton(
            onPressed: _copy,
            child: AnimatedSwitcher(
              duration: AppMotion.quick,
              child: Text(
                _copied ? AppStrings.guideCopied : AppStrings.guideCopy,
                key: ValueKey(_copied),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
