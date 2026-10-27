import "package:material_ui/material_ui.dart";

import "app.dart";
import "repositories/history_repository.dart";
import "utils/haptics.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryRepository.initialize();
  await HapticFeedback.initialize();
  runApp(const RokasNetApp());
}
