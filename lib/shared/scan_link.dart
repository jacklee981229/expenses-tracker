import 'package:flutter/widgets.dart';

import '../core/constants/app_info.dart';

/// Ticks each time the `expenses://app/scan` link opens the app; the root
/// shell listens and reads the clipboard.
final ValueNotifier<int> scanLinkTicks = ValueNotifier(0);

/// Whether this launch came through the scan link. The first route holds
/// it (just the path on some platforms, the whole link on Android), or it
/// was pushed before the shell was listening.
bool get openedByScanLink =>
    Uri.tryParse(
          WidgetsBinding.instance.platformDispatcher.defaultRouteName,
        )?.path ==
        kScanLinkPath ||
    scanLinkTicks.value > 0;

/// Catches the scan link before the app's navigator, which has no page for
/// it. Registered in `main` ahead of the app, so it is asked first.
class ScanLinkObserver with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    if (routeInformation.uri.path != kScanLinkPath) {
      return Future.value(false);
    }
    scanLinkTicks.value++;
    return Future.value(true);
  }
}
