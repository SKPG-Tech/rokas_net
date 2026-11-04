import "dart:io";

import "package:material_ui/material_ui.dart";
import "package:permission_handler/permission_handler.dart";

import "app.dart";
import "repositories/history_repository.dart";
import "utils/haptics.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryRepository.initialize();
  await HapticFeedback.initialize();

  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.status;
    while (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
  }

  runApp(RokasNetApp(historyProvider: .new()));
}
