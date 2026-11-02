import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart";
import "package:provider/provider.dart";

import "../models/history_entry.dart";
import "../providers/history_provider.dart";
import "../utils/haptics.dart";
import "../widgets/tab_icon.dart";

enum TimePeriod {
  today("Today"),
  yesterday("Yesterday"),
  thisWeek("This week"),
  thisMonth("This month"),
  older("Older");

  final String title;

  const TimePeriod(this.title);
}

extension FilterHistory on TimePeriod {
  Iterable<HistoryEntry> filter(Iterable<HistoryEntry> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const .new(days: 1));
    final thisMonth = DateTime(now.year, now.month);
    final filter = switch (this) {
      .today => (dt) => dt.isAfter(today),
      .yesterday => (dt) => dt.isAfter(yesterday) && dt.isBefore(today),
      .thisWeek => (dt) => now.difference(dt).inDays <= 7,
      .thisMonth => (dt) => dt.isAfter(thisMonth),
      .older => (dt) => dt.isBefore(thisMonth),
    };

    return history.where((e) => filter(e.dateTime));
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  final _expansibleControllers = <TimePeriod, ExpansibleController>{};
  RegExp? _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final searchQuery = _searchController.text.trim();
      setState(
        () => _searchQuery = searchQuery.isNotEmpty
            ? .new(RegExp.escape(searchQuery), caseSensitive: false)
            : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final historyProvider = context.watch<HistoryProvider>();

    Iterable<HistoryEntry> history = historyProvider.globalHistory;
    if (_searchQuery != null) {
      history = history.where((e) {
        var match = false;
        if (e.title != null) match |= _searchQuery!.hasMatch(e.title!);
        if (e.uri != null) match |= _searchQuery!.hasMatch(e.uri.toString());
        return match;
      });
    }

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
        appBar: AppBar(
          actionsPadding: const .only(right: 10),
          titleSpacing: 10,
          backgroundColor: colorScheme.surfaceContainer,
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search history",
              border: ShapedInputBorder(
                shape: RoundedRectangleBorder(
                  borderRadius: .all(.circular(25)),
                ),
              ),
            ),
          ),
          actions: [
            IconButton.filledTonal(
              onPressed: () async {
                final confirmation = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Are you sure?"),
                    content: const Text(
                      "This will delete the history of the past 2 hours.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(true),
                        style: .new(
                          foregroundColor: .all(colorScheme.tertiary),
                        ),
                        child: const Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () => context.pop(false),
                        style: .new(foregroundColor: .all(colorScheme.primary)),
                        child: const Text("No"),
                      ),
                    ],
                  ),
                );
                if (confirmation != null && confirmation && context.mounted)
                  context.read<HistoryProvider>().clearPast2HourHistory();
              },
              icon: const Icon(Symbols.delete_history_rounded),
            ),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: TimePeriod.values.map((timePeriod) {
            final filteredHistory = timePeriod.filter(history);
            final controller = _expansibleControllers.putIfAbsent(
              timePeriod,
              () => .new(),
            );
            if (_searchQuery != null && filteredHistory.isNotEmpty)
              controller.expand();
            return Expansible(
              controller: controller,
              headerBuilder: (_, animation) => ListTile(
                title: Text(timePeriod.title),
                trailing: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(animation),
                  child: const Icon(Icons.arrow_drop_down, size: 35),
                ),
                onTap: () => controller.isExpanded
                    ? controller.collapse()
                    : controller.expand(),
              ),
              bodyBuilder: (_, _) =>
                  _buildPeriod(timePeriod.filter(filteredHistory)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriod(Iterable<HistoryEntry> history) {
    if (history.isEmpty) {
      return const Text("Nothing");
    }

    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      primary: false,
      itemCount: history.length,
      itemBuilder: (context, i) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyles = Theme.of(context).textTheme;

        final entry = history.elementAt(i);

        final urlStyle = textStyles.bodyMedium!.copyWith(
          color: colorScheme.secondaryFixedDim,
        );
        final dateTimeStyle = textStyles.labelSmall!.copyWith(
          color: colorScheme.onSurface.withAlpha(150),
        );

        return InkWell(
          onTap: () => context.pop(entry),
          child: Dismissible(
            key: ValueKey(entry),
            onDismissed: (_) {
              context.read<HistoryProvider>().removeEntry(entry);
              ScaffoldMessenger.of(context).showSnackBar(
                .new(
                  content: Text(
                    "Removed history entry for ${entry.uri}",
                    style: .new(color: colorScheme.onTertiaryContainer),
                  ),
                  backgroundColor: colorScheme.tertiaryContainer,
                ),
              );
            },
            direction: .endToStart,
            background: Container(
              padding: const .only(right: 40),
              alignment: .centerRight,
              color: colorScheme.error,
              child: Icon(
                Symbols.delete_rounded,
                color: colorScheme.onError,
                size: 28,
              ),
            ),
            child: Padding(
              padding: const .symmetric(horizontal: 20, vertical: 5),
              child: Row(
                spacing: 10,
                children: [
                  Container(
                    padding: const .all(7.5),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: .circular(5),
                    ),
                    child: TabIcon(page: entry),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        if (entry.title != null)
                          Text(entry.title!, style: textStyles.titleMedium),
                        Text(
                          entry.uri.toString(),
                          style: urlStyle,
                          maxLines: 2,
                          overflow: .ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: .end,
                    children: [
                      Text(
                        DateFormat("HH:mm").format(entry.dateTime),
                        style: dateTimeStyle,
                      ),
                      Text(
                        DateFormat("MM-dd").format(entry.dateTime),
                        style: dateTimeStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
