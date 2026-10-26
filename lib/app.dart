import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/strings.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/icon_registry.dart';
import 'data/data_providers.dart';
import 'features/add_expense/add_expense_sheet.dart';
import 'features/analysis/analysis_screen.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/settings/settings_providers.dart';
import 'shared/scan_link.dart';
import 'shared/today_provider.dart';
import 'shared/widgets/floating_add_button.dart';
import 'shared/widgets/floating_tab_bar.dart';
import 'shared/widgets/glow_background.dart';

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

/// Two tabs, Ledger and Analysis, over the drifting glow background, with
/// the tab bar and the + button floating above them.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  static const int _ledgerTab = 0;
  static const List<FloatingTab> _tabs = [
    FloatingTab(label: AppStrings.tabLedger, icon: UiIcons.receipt),
    FloatingTab(label: AppStrings.tabAnalysis, icon: UiIcons.chart),
  ];

  int _tab = _ledgerTab;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    scanLinkTicks.addListener(_scanClipboard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _catchUp();
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
    setState(() => _tab = _ledgerTab);
    showAddExpenseSheet(
      context,
      reading: ref.read(receiptReaderProvider).readClipboard(),
      noPicture: AppStrings.scanNoPicture,
    );
  }

  void _onResume() {
    ref.read(todayProvider.notifier).refresh();
    _catchUp();
  }

  /// Adds any fixed monthly expenses that fell due since the last run.
  void _catchUp() {
    ref.read(recurringGeneratorProvider).catchUp();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(Theme.of(context).brightness),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GlowBackground(
          child: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    _TabPage(visible: _tab == 0, child: const LedgerScreen()),
                    _TabPage(visible: _tab == 1, child: const AnalysisScreen()),
                  ],
                ),
              ),
              Positioned(
                right: AppSpacing.lg,
                bottom:
                    AppSizes.tabBarBottom +
                    AppSizes.tabBarHeight +
                    AppSpacing.lg,
                child: SafeArea(
                  top: false,
                  child: FloatingAddButton(
                    tooltip: AppStrings.addExpense,
                    visible: _tab == _ledgerTab,
                    onPressed: () => showAddExpenseSheet(context),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSizes.tabBarBottom,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: FloatingTabBar(
                      tabs: _tabs,
                      selected: _tab,
                      onSelected: (index) => setState(() => _tab = index),
                    ),
                  ),
                ),
              ),
            ],
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
