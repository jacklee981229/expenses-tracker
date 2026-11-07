import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/strings.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/backup_timing.dart';
import 'core/utils/icon_registry.dart';
import 'data/data_providers.dart';
import 'features/add_expense/add_expense_sheet.dart';
import 'features/analysis/analysis_providers.dart';
import 'features/analysis/analysis_screen.dart';
import 'features/ledger/ledger_providers.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/settings/settings_providers.dart';
import 'features/settings/settings_screen.dart';
import 'shared/root_tab_provider.dart';
import 'shared/scan_link.dart';
import 'shared/today_provider.dart';
import 'shared/widgets/floating_add_button.dart';
import 'shared/widgets/floating_tab_bar.dart';
import 'shared/widgets/colour_field.dart';

/// Light and dark themes; Settings › Appearance picks one or follows the
/// phone, and switching cross-fades every colour.
class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: AppMotion.page,
      themeAnimationCurve: AppMotion.enter,
      scrollBehavior: const _BouncingScrollBehavior(),
      routes: {'/': (_) => const RootShell()},
      // A launch through the scan link asks for the `/scan` route, which has
      // no page: the shell opens and reads the clipboard instead.
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(builder: (_) => const RootShell()),
      ],
    );
  }
}

/// iOS scrolling everywhere: bouncing physics, no Android overscroll glow.
class _BouncingScrollBehavior extends MaterialScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

/// Three tabs, Ledger, Analysis and Settings, over the colour field of the
/// month or period on screen, with one row floating above them: the tab bar
/// on the left and the + button on the right.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  static const List<FloatingTab> _tabs = [
    FloatingTab(label: AppStrings.tabLedger, icon: UiIcons.receipt),
    FloatingTab(label: AppStrings.tabAnalysis, icon: UiIcons.chart),
    FloatingTab(label: AppStrings.settingsTitle, icon: UiIcons.gear),
  ];

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: _onResume,
      // shortcut: no iOS background task, so an upload gets the few seconds
      // iOS gives a hidden app (plenty for ~100 KB) and one cut off waits
      // for the next moment; add one if backups are seen missing.
      onHide: () => _backUp(BackupMoment.hidden),
    );
    scanLinkTicks.addListener(_scanClipboard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _catchUpThenBackUp();
      if (openedByScanLink) _scanClipboard();
    });
  }

  @override
  void dispose() {
    scanLinkTicks.removeListener(_scanClipboard);
    _lifecycle.dispose();
    super.dispose();
  }

  /// The Back Tap shortcut copied a screenshot and opened the scan link:
  /// show the ledger and an add sheet that fills from the clipboard picture.
  void _scanClipboard() {
    ref.read(rootTabProvider.notifier).select(RootTabNotifier.ledger);
    showAddExpenseSheet(
      context,
      scan: ref.read(receiptReaderProvider).clipboard(),
      noPicture: AppStrings.scanNoPicture,
    );
  }

  void _onResume() {
    ref.read(todayProvider.notifier).refresh();
    _catchUpThenBackUp();
  }

  /// Adds any fixed monthly expenses that fell due since the last run, then
  /// uploads a cloud backup if the last good one is old, so it holds them.
  void _catchUpThenBackUp() {
    ref
        .read(recurringGeneratorProvider)
        .catchUp()
        .whenComplete(() => _backUp(BackupMoment.opened));
  }

  Future<void> _backUp(BackupMoment moment) async {
    if (await ref.read(cloudBackupProvider).maybeUpload(moment) && mounted) {
      ref.invalidate(cloudBackupStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(rootTabProvider);
    final tabs = ref.read(rootTabProvider.notifier);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(Theme.of(context).brightness),
      // Android back on another tab returns to the ledger, as it did when
      // Settings was a pushed page, instead of closing the app.
      child: PopScope(
        canPop: tab == RootTabNotifier.ledger,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) tabs.select(RootTabNotifier.ledger);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ColourField(
            spots: ref.watch(
              tab == RootTabNotifier.analysis
                  ? analysisFieldProvider
                  : ledgerFieldProvider,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IndexedStack(
                    index: tab,
                    children: [
                      _TabPage(
                        visible: tab == RootTabNotifier.ledger,
                        child: const LedgerScreen(),
                      ),
                      _TabPage(
                        visible: tab == RootTabNotifier.analysis,
                        child: const AnalysisScreen(),
                      ),
                      _TabPage(
                        visible: tab == RootTabNotifier.settings,
                        child: const SettingsScreen(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSizes.tabBarBottom,
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FloatingTabBar(
                          tabs: _tabs,
                          selected: tab,
                          onSelected: tabs.select,
                        ),
                        FloatingAddButton(
                          tooltip: AppStrings.addExpense,
                          visible: tab != RootTabNotifier.settings,
                          onPressed: () => showAddExpenseSheet(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades and lifts a tab in each time it is shown.
class _TabPage extends StatelessWidget {
  const _TabPage({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.015),
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: AppMotion.slow,
        curve: AppMotion.enter,
        child: child,
      ),
    );
  }
}
