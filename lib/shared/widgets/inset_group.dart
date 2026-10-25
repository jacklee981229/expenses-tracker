import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';

/// A grouped section: an optional header row, a raised card with hairline
/// separators between its rows, and an optional footer.
class InsetGroup extends StatelessWidget {
  const InsetGroup({
    super.key,
    required this.children,
    this.header,
    this.headerTrailing,
    this.footer,
    this.onHeaderTap,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.separatorIndent = AppSpacing.md,
    this.headerInset = AppSpacing.xs,
    this.headerStyle,
  });

  final List<Widget> children;
  final String? header;

  /// Right-aligned header text, e.g. a day subtotal.
  final String? headerTrailing;
  final String? footer;
  final VoidCallback? onHeaderTap;

  /// The 16 page margin; zero when the parent already pads.
  final EdgeInsetsGeometry margin;

  /// Where each separator starts, from the card's left edge.
  final double separatorIndent;

  /// Horizontal inset of the header and footer text from the card edge.
  final double headerInset;

  /// Replaces the grey header style.
  final TextStyle? headerStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final headerStyle =
        this.headerStyle ??
        AppTextStyles.caption1.copyWith(color: colors.sectionLabel);
    final header = this.header;
    final headerTrailing = this.headerTrailing;
    final footer = this.footer;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null || headerTrailing != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHeaderTap,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  headerInset,
                  0,
                  headerInset,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    if (header != null)
                      Expanded(child: Text(header, style: headerStyle))
                    else
                      const Spacer(),
                    if (headerTrailing != null)
                      Text(headerTrailing, style: headerStyle),
                  ],
                ),
              ),
            ),
          DecoratedBox(
            decoration: cardDecoration(colors),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _withSeparators(context),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                headerInset,
                AppSpacing.xs,
                headerInset,
                0,
              ),
              child: Text(
                footer,
                style: AppTextStyles.footnote.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _withSeparators(BuildContext context) {
    final hairline = AppSizes.hairline(context);
    final separator = Divider(
      height: hairline,
      thickness: hairline,
      indent: separatorIndent,
      color: context.colors.separator,
    );
    return [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) separator,
        child,
      ],
    ];
  }
}
