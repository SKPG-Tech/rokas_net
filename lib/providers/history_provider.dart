import "package:flutter/foundation.dart";

import "../models/history_entry.dart";
import "../models/page.dart";
import "../repositories/history_repository.dart";

class HistoryProvider with ChangeNotifier {
  final History _globalHistory;

  HistoryProvider() : _globalHistory = HistoryRepository.loadHistory();

  History get globalHistory => _globalHistory;

  void addEntry(Page? page) {
    _globalHistory.add(HistoryEntry(url: page?.url, title: page?.title));
    notifyListeners();
  }

  void removeEntry(HistoryEntry entry) {
    entry.unlink();
    notifyListeners();
  }

  void clearPast2HourHistory() {
    final past2Hours = DateTime.now().subtract(const .new(hours: 2));
    final entries = _globalHistory.where((e) => e.dateTime.isAfter(past2Hours));
    for (final entry in entries.toList()) entry.unlink();
    notifyListeners();
  }
}
