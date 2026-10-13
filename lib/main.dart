import "package:material_ui/material_ui.dart";

import "app.dart";
import "repositories/history_repository.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryRepository.initialize();
  runApp(const RokasNetApp());
}
