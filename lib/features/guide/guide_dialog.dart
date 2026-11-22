import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/services/guide_store.dart';
import '../../shared/widgets/circle_icon_button.dart';
import '../../shared/widgets/sheets.dart';
import 'widgets/guide_page.dart';

/// First launch: asks once whether to see the guide. Either answer marks
/// it asked; Not now says where to find the guide later.
Future<void> askAboutGuide(BuildContext context, GuideStore store) async {
  if (await store.asked() || !context.mounted) return;
  final show = await showChoiceAlert(
    context,
    title: AppStrings.guideAskTitle,
    message: AppStrings.guideAskMessage,
    cancelLabel: AppStrings.guideNotNow,
    confirmLabel: AppStrings.guideShowMe,
  );
  await store.markAsked();
  if (!context.mounted) return;
  if (show) {
    await showGuide(context);
  } else {
    await showAlert(
      context,
      title: AppStrings.guideLaterTitle,
      message: AppStrings.guideLaterMessage,
    );
  }
}

/// The card grows in from this scale as it fades in.
const double _fromScale = 0.94;

/// The double-tap setup guide: five pages, each a drawn phone screen over
/// the theme's colours, a title and one line.
Future<void> showGuide(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppStrings.closeSheet,
    // The dim is drawn below with the theme's colour read on every build,
    // not passed here, where it would freeze at the colour of the moment
    // the guide opened (the sheets' trap in CLAUDE.md).
    barrierColor: Colors.transparent,
    transitionDuration: AppMotion.slow,
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.pop,
        reverseCurve: AppMotion.exit,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppMotion.enter),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: context.colors.shadow),
              ),
            ),
            ScaleTransition(
              scale: Tween<double>(begin: _fromScale, end: 1).animate(curved),
              child: child,
            ),
          ],
        ),
      );
    },
    pageBuilder: (context, _, _) => const _GuideCard(),
  );
}

class _GuideCard extends StatefulWidget {
  const _GuideCard();

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  static const List<(String, List<String>)> _pages = [
    (AppStrings.guideNewTitle, [AppStrings.guideNewBody]),
    (AppStrings.guideActionsTitle, AppStrings.guideActionsSteps),
    (AppStrings.guideBackTapTitle, [AppStrings.guideBackTapBody]),
    (AppStrings.guideDoubleTitle, [AppStrings.guideDoubleBody]),
    (AppStrings.guideTryTitle, [AppStrings.guideTryBody]),
  ];

  final PageController _pager = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _turn(int by) {
    final next = _page + by;
    if (next < 0) return;
    if (next >= _pages.length) {
      Navigator.of(context).pop();
      return;
    }
    _pager.animateToPage(
      next,
      duration: AppMotion.slow,
      curve: AppMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final last = _page == _pages.length - 1;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.guideMaxWidth),
            child: Material(
              color: colors.sheetBackground,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sheet),
                side: BorderSide(color: colors.glassEdge),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flexible: on a short screen, or with large text, the
                  // pages give up height (their text scrolls) so the
                  // buttons stay on screen.
                  Flexible(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: AppSizes.guidePageHeight,
                          child: PageView.builder(
                            controller: _pager,
                            itemCount: _pages.length,
                            onPageChanged: (page) =>
                                setState(() => _page = page),
                            itemBuilder: (context, index) => GuidePage(
                              index: index,
                              title: _pages[index].$1,
                              lines: _pages[index].$2,
                            ),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: CircleIconButton(
                            icon: Icons.close_rounded,
                            tooltip: AppStrings.closeSheet,
                            background: colors.tile,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xs,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedOpacity(
                              opacity: _page == 0 ? 0 : 1,
                              duration: AppMotion.quick,
                              child: TextButton(
                                onPressed: _page == 0 ? null : () => _turn(-1),
                                child: const Text(AppStrings.guideBack),
                              ),
                            ),
                          ),
                        ),
                        _Dots(count: _pages.length, current: _page),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: () => _turn(1),
                              child: AnimatedSwitcher(
                                duration: AppMotion.quick,
                                child: Text(
                                  last ? AppStrings.done : AppStrings.next,
                                  key: ValueKey(last),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.enter,
            margin: const EdgeInsets.symmetric(
              horizontal: AppSizes.guideDotGap,
            ),
            width: i == current ? AppSizes.guideDotActive : AppSizes.guideDot,
            height: AppSizes.guideDot,
            decoration: BoxDecoration(
              color: i == current ? colors.label : colors.labelTertiary,
              borderRadius: BorderRadius.circular(AppSizes.guideDot),
            ),
          ),
      ],
    );
  }
}
