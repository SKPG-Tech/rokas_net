import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../controllers/crossplatform_webview_controller.dart";
import "../providers/history_provider.dart";
import "../providers/tab_provider.dart";
import "../utils/ui.dart";
import "../widgets/browser_appbar.dart";
import "../widgets/crossplatform_webview.dart";
import "../widgets/history_button.dart";
import "../widgets/nav_drawer.dart";

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
  late final FocusNode _urlFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _webviewController.initialize();
    _urlFieldFocusNode = .new();
  }

  @override
  void dispose() {
    _webviewController.dispose();
    _urlFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uri = context.select((TabProvider provider) => provider.tab?.uri);
    if (uri != null) setState(() => _webviewController.navigateTo(uri));

    return Consumer<TabProvider>(
      builder: (context, tabProvider, _) {
        final tab = tabProvider.tab;

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: BrowserAppBar(
            initialUri: tab?.uri,
            urlFieldFocusNode: _urlFieldFocusNode,
            onBackwardPressed: tabProvider.backwardHandler,
            onForwardPressed: tabProvider.forwardHandler,
            onUriSubmitted: (value) {
              if (!value.startsWith(RegExp(r"https?:\/\/")))
                value = "https://$value";

              final uri = Uri.parse(value);
              if (uri == tab?.uri) return;

              tabProvider.navigateTab(uri);
              context.read<HistoryProvider>().addEntry(uri);
              _urlFieldFocusNode.unfocus();
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
              _urlFieldFocusNode.requestFocus();
            },
            onCloseTabPressed: (tab) => tabProvider.closeTab(tab),
          ),
          body: tab == null
              ? _NewTabView(urlFieldFocusNode: _urlFieldFocusNode)
              : CrossplatformWebview(controller: _webviewController),
        );
      },
    );
  }
}

class _NewTabView extends StatelessWidget {
  final FocusNode _urlFieldFocusNode;

  const _NewTabView({required this._urlFieldFocusNode});

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
                      onPressed: () {
                        context.read<TabProvider>().openNewTab();
                        _urlFieldFocusNode.requestFocus();
                      },
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
