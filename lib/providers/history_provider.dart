import "package:flutter/foundation.dart";

import "../models/history_entry.dart";

class HistoryProvider with ChangeNotifier {
  final _globalHistory = History();

  HistoryProvider();

  History get globalHistory => _globalHistory;

  void addEntry(Uri uri) {
    _globalHistory.add(HistoryEntry(uri: uri));
  }
}
