import "package:go_router/go_router.dart";
import "package:material_ui/material_ui.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";

import "../models/history_entry.dart";
import "../providers/history_provider.dart";
import "../utils/haptics.dart";
import "../widgets/tab_icon.dart";

enum TimePeriod { lastHour, today, thisWeek, thisMonth }

extension FilterHistory on TimePeriod {
  Iterable<HistoryEntry> filter(History history) {
    final now = DateTime.now();
    final today = now.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: 0,
      millisecond: 0,
    );
    final filter = switch (this) {
      .lastHour => (dt) => now.difference(dt).inMinutes <= 60,
      .today => (dt) => dt.isAfter(today),
      .thisWeek => (dt) => now.difference(dt).inDays <= 7,
      .thisMonth => (dt) => now.difference(dt).inDays <= 31,
    };

    return history.where((e) => filter(e.dateTime));
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final historyProvider = context.read<HistoryProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (context.mounted) {
          Navigator.pop(context);
          HapticFeedback.play(.quickFall);
        }
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: colorScheme.surfaceContainer),
        body: ListView(
          shrinkWrap: true,
          children:
              TimePeriod.values
                  .map((timePeriod) {
                    final expansibleController = ExpansibleController();
                    return Expansible(
                      controller: expansibleController,
                      headerBuilder: (_, _) => ListTile(
                        title: Text(timePeriod.name),
                        onTap: () {
                          if (expansibleController.isExpanded) {
                            expansibleController.collapse();
                          } else {
                            expansibleController.expand();
                          }
                        },
                      ),
                      bodyBuilder: (_, _) => _buildHistory(
                        historyProvider.globalHistory,
                        timePeriod,
                      ),
                    );
                  })
                  .cast<Widget>()
                  .toList()
                ..addAll([
                  FutureBuilder(
                    future: getExternalStorageDirectories(),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? ListView(
                              shrinkWrap: true,
                              children: snapshot.data!
                                  .map((e) => Text(e.toString()))
                                  .toList(),
                            )
                          : const SizedBox();
                    },
                  ),
                ]),
        ),
      ),
    );
  }

  Widget _buildHistory(History history, TimePeriod timePeriod) {
    final filterHistory = timePeriod.filter(history);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filterHistory.length,
      itemBuilder: (context, i) {
        final entry = filterHistory.elementAt(i);
        return Padding(
          padding: const .symmetric(horizontal: 20),
          child: InkWell(
            onTap: () => context.pop(entry),
            child: Row(
              spacing: 30,
              children: [
                TabIcon(page: entry),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (entry.title != null) Text(entry.title!),
                    Text(entry.uri.toString()),
                  ],
                ),
                Text(entry.dateTime.toString()),
              ],
            ),
          ),
        );
      },
    );
  }
}
