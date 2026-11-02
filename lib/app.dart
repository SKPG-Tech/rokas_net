import "dart:ui";

import "package:material_ui/material_ui.dart";
import "package:provider/provider.dart";

import "providers/history_provider.dart";
import "providers/tab_provider.dart";
import "repositories/history_repository.dart";
import "routes.dart";

class RokasNetApp extends StatefulWidget {
  final HistoryProvider historyProvider;

  const RokasNetApp({super.key, required this.historyProvider});

  @override
  State<RokasNetApp> createState() => _RokasNetAppState();
}

class _RokasNetAppState extends State<RokasNetApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (<AppLifecycleState>{.inactive, .detached}.contains(state)) {
      final history = widget.historyProvider.globalHistory;
      HistoryRepository.saveHistory(history);
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (!mounted) return .exit;

    final history = widget.historyProvider.globalHistory;
    HistoryRepository.saveHistory(history);

    return .exit;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider.value(value: widget.historyProvider),
      ],
      child: MaterialApp.router(
        title: "RokasNet",
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 0, 255),
            brightness: .dark,
          ),
        ),
      ),
    );
  }
}
