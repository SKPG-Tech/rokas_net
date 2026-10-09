import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

import "screens/browser_screen.dart";

import "app.dart";

abstract final class _Routes {
  static const browser = "/browser";
  static const browserTab = ":tab";

  static const tabs = "/tabs";
  static const history = "/history";
}

extension AppNavigation on BuildContext {
  void goBrowser({required int tab}) => go("${_Routes.browser}/$tab");

  void pushTabs() => push(_Routes.tabs);
  void pushHistory() => push(_Routes.history);
}

final appRouter = GoRouter(
  initialLocation: _Routes.browser,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, navigationShell) =>
          AppScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: _Routes.browser,
              builder: (_, _) => const BrowserScreen(),
              routes: [
                GoRoute(
                  path: _Routes.browserTab,
                  builder: (_, state) {
                    final tab = state.pathParameters["tab"];
                    return BrowserScreen(
                      tab: tab != null ? .tryParse(tab) : null,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
