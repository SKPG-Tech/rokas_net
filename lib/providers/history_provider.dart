import "package:flutter/foundation.dart";

import "../models/history_entry.dart";
import "../models/page.dart";
import "../repositories/history_repository.dart";

class HistoryProvider with ChangeNotifier {
  final History _globalHistory;

  HistoryProvider() : _globalHistory = HistoryRepository.loadHistory();

  History get globalHistory => _globalHistory;

  void addEntry(Page? page) {
    _globalHistory.add(HistoryEntry(uri: page?.uri, title: page?.title));
    notifyListeners();
  }

  void removeEntry(HistoryEntry entry) {
    entry.unlink();
    notifyListeners();
  }

  void clearHistory() {
    _globalHistory.clear();
    notifyListeners();
  }
}
