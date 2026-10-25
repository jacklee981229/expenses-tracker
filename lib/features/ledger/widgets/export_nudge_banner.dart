import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../settings/settings_screen.dart';
import '../ledger_providers.dart';

/// "Back up your data" banner above the ledger list. Exports are the backup
/// strategy, since reinstalls wipe the app's data. Tap to open Settings;
/// dismissing hides it for the rest of the session.
class ExportNudgeBanner extends ConsumerWidget {
  const ExportNudgeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nudge = ref.watch(exportNudgeProvider);
    if (nudge == null) return const SizedBox.shrink();
    final colors = context.colors;
    final days = nudge.daysSinceExport;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
        child: DecoratedBox(
          decoration: cardDecoration(colors, radius: AppRadius.tile),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.cloud_upload_rounded,
                size: AppSizes.bannerIcon,
                color: colors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  days == null
                      ? AppStrings.exportNudgeNever
                      : AppStrings.exportNudge(days),
                  style: AppTextStyles.subheadline,
                ),
              ),
              IconButton(
                tooltip: AppStrings.dismiss,
                icon: Icon(
                  Icons.close,
                  size: AppSizes.bannerIcon,
                  color: colors.labelSecondary,
                ),
                onPressed: ref
                    .read(exportNudgeDismissedProvider.notifier)
                    .dismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
