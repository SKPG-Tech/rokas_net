import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../controllers/crossplatform_webview_controller.dart";
import "../models/tab.dart";
import "../providers/history_provider.dart";
import "../providers/tab_provider.dart";
import "../utils/ui.dart";
import "../widgets/browser_appbar.dart";
import "../widgets/crossplatform_webview.dart";
import "../widgets/history_button.dart";
import "../widgets/nav_drawer.dart";

void _createNewTab(BuildContext context) =>
    context.read<TabProvider>().openNewTab(uri: .parse("https://google.com"));

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _webviewController = CrossplatformWebviewController(
    delegate: () => .new(),
  );

  @override
  void dispose() {
    // _webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, _) {
        final tab = tabProvider.tab;
        return Scaffold(
          key: _scaffoldKey,
          appBar: BrowserAppBar(
            initialUri: tab?.uri,
            onBackwardPressed: tabProvider.backwardHandler,
            onForwardPressed: tabProvider.forwardHandler,
            onUriSubmitted: (value) {
              final uri = Uri.parse(value);
              if (uri == tab?.uri) return;

              tabProvider.navigateTab(uri);
              setState(() => _webviewController.navigateTo(uri));
              context.read<HistoryProvider>().addEntry(uri);
            },
          ),
          endDrawer: NavDrawer(
            tabs: tabProvider.tabs,
            selectedIndex: tabProvider.selectedTab,
            onDestinationSelected: (value) {
              tabProvider.selectTab(value);
              _scaffoldKey.currentState?.closeEndDrawer();
            },
            onNewTabPressed: () => _createNewTab(context),
            onCloseTabPressed: (tab) => tabProvider.closeTab(tab),
          ),
          body: tab == null
              ? const _NewTabView()
              : CrossplatformWebview(controller: _webviewController),
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
                      onPressed: () => _createNewTab(context),
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

class _TabView extends StatelessWidget {
  final Tab _tab;

  const _TabView({required this._tab});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Text(_tab.uri.toString());
  }
}
