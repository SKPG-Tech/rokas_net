import "package:flutter/foundation.dart";

import "../models/history_entry.dart";
import "../repositories/history_repository.dart";

class HistoryProvider with ChangeNotifier {
  final History _globalHistory;

  HistoryProvider() : _globalHistory = HistoryRepository.loadHistory();

  History get globalHistory => _globalHistory;

  void addEntry(Uri uri) {
    _globalHistory.add(HistoryEntry(uri: uri));
    HistoryRepository.saveHistory(_globalHistory);
  }
}
