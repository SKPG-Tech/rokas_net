import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../controllers/in_app_webview_controller.dart";
import "../providers/tab_provider.dart";
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, _) {
        final tab = tabProvider.tab;

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: BrowserAppBar(
            initialUrl: tab?.url,
            onBackwardPressed: tabProvider.backwardHandler,
            onForwardPressed: tabProvider.forwardHandler,
            onUrlSubmitted: (value) {
              if (!value.startsWith(RegExp(r"https?:\/\/")))
                value = "https://$value";

              final url = WebUri(value);
              if (url == tab?.url) return;

              _webviewController.loadUrl(url);
            },
          ),
          endDrawer: NavDrawer(
            tabs: tabProvider.tabs,
            selectedIndex: tabProvider.tabIndex,
            onDestinationSelected: (value) {
              tabProvider.selectTab(value);
              _scaffoldKey.currentState?.closeEndDrawer();
            },
            onNewTabPressed: () {
              tabProvider.openNewTab();
            },
            onCloseTabPressed: (tab) => tabProvider.closeTab(tab),
          ),
          body: tab == null
              ? const _NewTabView()
              : InAppWebView(
                  onWebViewCreated: _webviewController.onWebViewCreated,
                  onLoadStop: (controller, url) async {
                    tabProvider.navigateTab(url!.uriValue);
                    final icon = await _webviewController.getIcon();
                tab.favicon = icon?.url.toString();
                  },
                  onTitleChanged: (_, title) => print("TITLE: $title"),
                ),
        );
      },
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
