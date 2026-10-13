import "dart:convert";
import "dart:io";

import "package:path_provider/path_provider.dart";

import "../models/history_entry.dart";

abstract final class HistoryRepository {
  static late final String _historyFilePath;

  static Future<void> initialize() async {
    final folderPath = await getDownloadsDirectory();
    _historyFilePath = "${folderPath?.path}/istorija.json";
  }

  static File get _historyFile => File(_historyFilePath);

  static void saveHistory(History history) {
    final json = jsonEncode(history.map((e) => e.toJson()).toList());
    _historyFile.writeAsStringSync(json);
  }

  static History loadHistory() {
    if (!_historyFile.existsSync()) return .new();

    final List<dynamic> json = jsonDecode(_historyFile.readAsStringSync());
    return .new()..addAll(json.map((e) => HistoryEntry.fromJson(e)));
  }
}
