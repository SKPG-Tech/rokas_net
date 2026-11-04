import "dart:io";

import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../app.dart";
import "../controllers/in_app_webview_controller.dart";
import "../providers/history_provider.dart";
import "../providers/tab_provider.dart";
import "../utils/haptics.dart";
import "../utils/ui.dart";
import "../widgets/browser_appbar.dart";
import "../widgets/history_button.dart";
import "../widgets/nav_drawer.dart";

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _webviewController = InAppWebviewController();

  static final _kIsAndroid = Platform.isAndroid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  VoidCallback? _goForwardHandler(TabProvider tabProvider) {
    if (!tabProvider.canGoForward) return null;
    return () {
      tabProvider.goForward();
      _webviewController.loadUrl(tabProvider.tab!.url!);
    };
  }

  VoidCallback? _goBackwardHandler(TabProvider tabProvider) {
    if (!tabProvider.canGoBackward) return null;
    return () {
      tabProvider.goBackward();
      _webviewController.loadUrl(tabProvider.tab!.url!);
    };
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = context.watch<TabProvider>();
    final historyProvider = context.read<HistoryProvider>();

    final tab = tabProvider.tab;
    final initialRequest = _kIsAndroid && tab?.url == null;

    final body = tab == null
        ? const _NewTabView()
        : InAppWebView(
            key: ValueKey(tab),
            initialUrlRequest: !initialRequest ? .new(url: tab.url) : null,
            onWebViewCreated: _webviewController.onWebViewCreated,
            onLoadStop: (controller, url) async {
              final shouldSave = _webviewController.shouldSave;
              tabProvider.navigateTab(url!, shouldSave: shouldSave);
              final icon = await _webviewController.getIcon();
              tab.favicon = icon?.url.toString();
              if (shouldSave) historyProvider.addEntry(tab);
            },
            onTitleChanged: (_, title) => tab.title = title,
          );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final drawerState = _scaffoldKey.currentState;
        if (drawerState != null && drawerState.isEndDrawerOpen) {
          drawerState.closeEndDrawer();
          return;
        }
        final swipeEdge = context.read<NavigationGesture>();
        if (swipeEdge.value == null) return;
        final action = switch (swipeEdge.value!) {
          .left => _goBackwardHandler(tabProvider),
          .right => _goForwardHandler(tabProvider),
        };
        if (action == null) await HapticFeedback.play(.thud);
        if (action != null) {
          action();
          await HapticFeedback.play(.spin);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: BrowserAppBar(
          tab: tab,
          onBackwardPressed: _goBackwardHandler(tabProvider),
          onForwardPressed: _goForwardHandler(tabProvider),
          onUrlSubmitted: (value) {
            if (!value.startsWith(RegExp(r"https?:\/\/")))
              value = "https://$value";

            final url = WebUri(value);
            if (url == tab?.url) return;

            _webviewController.loadUrl(url, shouldSave: true);
          },
        ),
        endDrawer: NavDrawer(
          tabs: tabProvider.tabs,
          selectedIndex: tabProvider.tabIndex,
          onDestinationSelected: (value) {
            tabProvider.selectTab(value);
            if (tab!.url != null) _webviewController.loadUrl(tab.url!);
            _scaffoldKey.currentState?.closeEndDrawer();
          },
          onNewTabPressed: tabProvider.openNewTab,
          onCloseTabPressed: tabProvider.closeTab,
        ),
        body: body,
      ),
    );
  }
}

class _NewTabView extends StatelessWidget {
  const _NewTabView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Center(
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: .blur(sigmaX: 75, sigmaY: 100),
            child: Container(
              width: 275,
              height: 400,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: .circular(30),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text("Get started!", style: textStyles.displaySmall),
                Text(
                  "You currently have no tabs open",
                  style: textStyles.titleMedium!.copyWith(
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                ),
                addVerticalGap(50),
                SizedBox(
                  width: 150,
                  child: Text(
                    "Start by creating a tab, or view your history",
                    textAlign: .center,
                    style: textStyles.titleSmall,
                  ),
                ),
                addVerticalGap(20),
                Row(
                  mainAxisAlignment: .center,
                  spacing: 15,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => context.read<TabProvider>().openNewTab(),
                      style: .new(
                        backgroundColor: .all(colorScheme.secondaryContainer),
                        fixedSize: .all(const .fromHeight(48)),
                        iconSize: .all(24),
                      ),
                      icon: const Icon(Symbols.add_box),
                      label: const Text("New tab"),
                    ),
                    const HistoryButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
