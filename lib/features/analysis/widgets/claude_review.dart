import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/data_providers.dart';
import '../../../shared/widgets/pressable.dart';

/// The report's last section: on a tap, Claude's few sentences on the
/// report's figures. Nothing is sent until Jack asks.
class ClaudeReview extends ConsumerStatefulWidget {
  const ClaudeReview({super.key, required this.apiKey, required this.brief});

  final String apiKey;

  /// Builds the figures as text; only called when Jack asks.
  final String Function() brief;

  @override
  ConsumerState<ClaudeReview> createState() => _ClaudeReviewState();
}

enum _Stage { ask, writing, failed }

class _ClaudeReviewState extends ConsumerState<ClaudeReview> {
  _Stage _stage = _Stage.ask;
  String? _review;

  Future<void> _ask() async {
    setState(() => _stage = _Stage.writing);
    final review = await ref
        .read(claudeApiProvider)
        .reviewReport(key: widget.apiKey, brief: widget.brief());
    if (!mounted) return;
    setState(() {
      _review = review;
      if (review == null) _stage = _Stage.failed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const style = AppTextStyles.reportLine;
    final review = _review;
    if (review != null) {
      return Text(review, style: style.copyWith(color: colors.label));
    }
    return switch (_stage) {
      _Stage.writing => Text(
        AppStrings.reportClaudeWriting,
        style: style.copyWith(color: colors.labelSecondary),
      ),
      _Stage.ask || _Stage.failed => Semantics(
        button: true,
        child: Pressable(
          onTap: _ask,
          child: Text(
            _stage == _Stage.ask
                ? AppStrings.reportAskClaude
                : AppStrings.reportClaudeFailed,
            style: style.copyWith(color: colors.accent),
          ),
        ),
      ),
    };
  }
}
