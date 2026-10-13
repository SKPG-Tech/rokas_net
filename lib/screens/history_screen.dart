import "package:material_ui/material_ui.dart";
import "package:provider/provider.dart";

import "../providers/history_provider.dart";

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final historyProvider = context.read<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(backgroundColor: colorScheme.surfaceContainer),
      body: Column(children: _buildHistory(historyProvider)),
    );
  }

  List<Widget> _buildHistory(HistoryProvider historyProvider) {
    return [
      for (final entry in historyProvider.globalHistory)
        Text("${entry.uri.toString()} - ${entry.dateTime}"),
    ];
  }
}
