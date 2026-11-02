import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;

import "../models/tab.dart";
import "../utils/ui.dart";
import "history_button.dart";
import "tab_icon.dart";

class NavDrawer extends StatelessWidget {
  final Tabs tabs;
  final int? selectedIndex;

  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onNewTabPressed;
  final ValueChanged<Tab> onCloseTabPressed;

  const NavDrawer({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onNewTabPressed,
    required this.onCloseTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      header: Column(
        children: [
          Padding(
            padding: const .fromLTRB(15, 20, 0, 10),
            child: Row(
              crossAxisAlignment: .end,
              spacing: 10,
              children: [
                const Icon(
                  Symbols.captive_portal_rounded,
                  size: 48,
                  opticalSize: 48,
                  weight: 600,
                ),
                Text("RokasNet", style: textStyles.headlineMedium),
              ],
            ),
          ),
          drawerDivider(),
          Padding(
            padding: const .only(left: 25, top: 10, right: 25),
            child: Flex(
              direction: .horizontal,
              spacing: 8,
              children: [
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      const Icon(Icons.tab_rounded, size: 20),
                      Text(
                        tabs.isEmpty ? "No tabs" : "${tabs.length} Tabs",
                        style: textStyles.titleMedium,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onNewTabPressed,
                  style: .new(
                    backgroundColor: .all(colorScheme.surfaceContainerHigh),
                  ),
                  icon: const Icon(Symbols.add_box),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: const Padding(
        padding: .symmetric(vertical: 20),
        child: HistoryButton(),
      ),
      children: [
        addVerticalGap(10),
        ...tabs.map(
          (tab) => _NavigationDestination(
            icon: TabIcon(page: tab),
            label: SizedBox(
              width: 180,
              child: Text(
                tab.title ?? "New tab",
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ),
            onClosePressed: () => onCloseTabPressed(tab),
          ),
        ),
      ],
    );
  }
}

// Very hacky
class _NavigationDestination extends NavigationDrawerDestination {
  final VoidCallback? onClosePressed;

  const _NavigationDestination({
    required super.icon,
    required super.label,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        super.build(context),
        SizedBox(
          height: 56,
          child: Align(
            alignment: .centerRight,
            child: Padding(
              padding: const .only(right: 25),
              child: SizedBox(
                width: 32,
                height: 32,
                child: IconButton.filledTonal(
                  onPressed: onClosePressed,
                  style: .new(
                    iconSize: .all(16),
                    backgroundColor: .all(colorScheme.surfaceContainerHigh),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
