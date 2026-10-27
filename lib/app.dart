import "package:material_ui/material_ui.dart";
import "package:provider/provider.dart";

import "providers/history_provider.dart";
import "providers/tab_provider.dart";
import "routes.dart";

class RokasNetApp extends StatelessWidget {
  const RokasNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
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
