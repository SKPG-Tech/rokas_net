import "package:go_router/go_router.dart";
import "package:material_ui/material_ui.dart" hide Page;

import "models/page.dart";
import "screens/browser_screen.dart";
import "screens/history_screen.dart";

abstract final class _Routes {
  static const browser = "/browser";
  static const history = "/history";
}

extension AppNavigation on BuildContext {
  void goBrowser() => go(_Routes.browser);
  Future<Page?> pushHistory() async => await push(_Routes.history);
}

final appRouter = GoRouter(
  initialLocation: _Routes.browser,
  routes: [
    GoRoute(path: _Routes.browser, builder: (_, _) => const BrowserScreen()),
    GoRoute(
      path: _Routes.history,
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HistoryScreen(),
        transitionsBuilder: (_, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const .new(0, 1), end: .zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOutExpo),
          ),
          child: child,
        ),
      ),
    ),
  ],
);
