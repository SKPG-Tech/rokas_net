import "package:material_ui/material_ui.dart";

import "../routes.dart";

class HistoryButton extends StatelessWidget {
  const HistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return TextButton.icon(
      onPressed: () async {
        if (context.mounted) await context.pushHistory();
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
