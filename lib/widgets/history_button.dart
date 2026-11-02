import "package:material_ui/material_ui.dart" hide Page;
import "package:provider/provider.dart";

import "../providers/tab_provider.dart";
import "../routes.dart";
import "../utils/haptics.dart";

class HistoryButton extends StatelessWidget {
  const HistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return TextButton.icon(
      onPressed: () async {
        await HapticFeedback.play(.quickRise);
        if (!context.mounted) return;
        final result = await context.pushHistory();
        if (result != null && context.mounted) {
          final tabProvider = context.read<TabProvider>();
          tabProvider.openNewTab(url: result.url);
          final tabs = tabProvider.tabs.indexed;
          final createdTab = tabs.first.$2;
          tabProvider.selectTab(
            tabs.firstWhere((e) => identical(e.$2, createdTab)).$1,
          );
          Scaffold.of(context).closeEndDrawer();
        }
      },
      icon: const Icon(Icons.history_rounded),
      style: .new(
        fixedSize: .all(const .fromHeight(48)),
        elevation: .all(0),
        alignment: .centerLeft,
        iconSize: .all(24),
        textStyle: .all(textStyles.labelLarge),
        backgroundColor: .all(colorScheme.onSecondary),
      ),
      label: const Text("History"),
    );
  }
}
