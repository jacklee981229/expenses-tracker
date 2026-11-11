import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/split_settle.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/picture_share.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/colour_field.dart';
import '../split_providers.dart';
import 'person_avatar.dart';

/// Opens who pays whom for [group]: the payments, everyone's balance, and
/// Share as picture. The result only shows here, never on the page.
Future<void> showSettleSheet(BuildContext context, SplitGroup group) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.page,
      reverseDuration: AppMotion.normal,
    ),
    builder: (context) => _SettleSheet(group),
  );
}

class _SettleSheet extends ConsumerStatefulWidget {
  const _SettleSheet(this.group);

  final SplitGroup group;

  @override
  ConsumerState<_SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends ConsumerState<_SettleSheet> {
  bool _sharing = false;

  Future<void> _share(SplitSummary summary) async {
    setState(() => _sharing = true);
    try {
      await shareOffscreen(
        context,
        SettleCard(group: widget.group, summary: summary),
        width: AppSizes.settleCardWidth,
        fileName: AppStrings.settleFileName,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final summary = ref
        .watch(splitSummaryProvider(widget.group.id))
        .valueOrNull;
    if (summary == null) return const SizedBox.shrink();
    final payments = summary.payments;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * AppSizes.reportMaxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            // The theme's drag handle already gives the top its room.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              AppStrings.settleUp,
              style: AppTextStyles.title2.copyWith(color: colors.label),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: cardDecoration(colors),
                    child: payments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Text(
                              AppStrings.allSquare,
                              style: AppTextStyles.title3.copyWith(
                                color: colors.label,
                              ),
                            ),
                          )
                        : PaymentList(summary: summary, inApp: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  BalanceChips(summary: summary),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            child: FilledButton.icon(
              onPressed: _sharing || payments.isEmpty
                  ? null
                  : () => _share(summary),
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text(AppStrings.shareAsPicture),
            ),
          ),
        ],
      ),
    );
  }
}

/// Who pays whom, one payment a row, hairlines between: both people's
/// initials with an arrow, their names, the amount big on the right.
/// [inApp] says "You" for Jack and puts "pays …" under the payer; the
/// shared picture uses his name, all on one line.
class PaymentList extends StatelessWidget {
  const PaymentList({super.key, required this.summary, required this.inApp});

  final SplitSummary summary;
  final bool inApp;

  @override
  Widget build(BuildContext context) {
    final payments = summary.payments;
    return Column(
      children: [
        for (final (index, payment) in payments.indexed) ...[
          if (index > 0)
            Divider(
              height: AppSizes.hairline(context),
              thickness: AppSizes.hairline(context),
              color: context.colors.separator,
            ),
          _PaymentRow(summary: summary, payment: payment, inApp: inApp),
        ],
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.summary,
    required this.payment,
    required this.inApp,
  });

  final SplitSummary summary;
  final SplitPayment payment;
  final bool inApp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final people = summary.people;
    final from = summary.person(payment.from);
    final to = summary.person(payment.to);
    String name(SplitPerson p) => inApp && p.isMe ? AppStrings.you : p.name;
    final strong = AppTextStyles.rowTitle.copyWith(color: colors.label);
    final quiet = AppTextStyles.footnote.copyWith(color: colors.labelSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          PersonAvatar(name: from.name, index: people.indexOf(from)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: AppSizes.labelIcon,
              color: colors.labelTertiary,
            ),
          ),
          PersonAvatar(name: to.name, index: people.indexOf(to)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: inApp
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name(from),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: strong,
                      ),
                      Text(
                        to.isMe
                            ? AppStrings.paysYou
                            : from.isMe
                            ? AppStrings.payWhom(to.name)
                            : AppStrings.paysWhom(to.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: quiet,
                      ),
                    ],
                  )
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: from.name, style: strong),
                        TextSpan(text: ' ${AppStrings.pays} ', style: quiet),
                        TextSpan(text: to.name, style: strong),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            formatWithSymbol(payment.amount),
            style: AppTextStyles.title3.copyWith(color: colors.label),
          ),
        ],
      ),
    );
  }
}

/// Everyone's balance as small chips: green is owed, red owes.
class BalanceChips extends StatelessWidget {
  const BalanceChips({super.key, required this.summary});

  final SplitSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final (index, person) in summary.people.indexed)
          Container(
            height: AppSizes.chipHeight,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxs + 2,
              0,
              AppSpacing.sm,
              0,
            ),
            decoration: cardDecoration(colors, radius: AppRadius.chip),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PersonAvatar(
                  name: person.name,
                  index: index,
                  size: AppSizes.personChipAvatar,
                ),
                const SizedBox(width: AppSpacing.xxs + 2),
                Text(
                  person.isMe ? AppStrings.you : person.name,
                  style: AppTextStyles.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs + 2),
                Text(
                  formatBalance(summary.balances[person.id] ?? 0),
                  style: AppTextStyles.chipFigure.copyWith(
                    color: switch (summary.balances[person.id] ?? 0) {
                      > 0 => colors.changeDown,
                      < 0 => colors.changeUp,
                      _ => colors.labelSecondary,
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The shared picture: the group on its own colours, its days, people and
/// spending, then only who pays whom, big enough to read as a chat
/// thumbnail.
class SettleCard extends StatelessWidget {
  const SettleCard({super.key, required this.group, required this.summary});

  final SplitGroup group;
  final SplitSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = AppTextStyles.footnote.copyWith(color: colors.sectionLabel);
    return ColourField(
      spots: summary.field,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              group.name,
              style: AppTextStyles.largeTitle.copyWith(color: colors.label),
            ),
            Text(
              AppStrings.groupSpent(
                summary.dayRange,
                summary.people.length,
                formatWithSymbol(summary.totalMinor),
              ),
              style: small,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              decoration: cardDecoration(colors),
              child: PaymentList(summary: summary, inApp: false),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(AppStrings.splitFooter(summary.entryCount), style: small),
                const Spacer(),
                Text(AppStrings.appTitle, style: small),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
