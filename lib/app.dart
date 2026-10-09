import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

import "routes.dart";
import "styles.dart";

class RokasNetApp extends StatelessWidget {
  const RokasNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider.value(value: 1)],
      child: MaterialApp.router(
        title: "RokasNet",
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: Styles.colors, textTheme: Styles.text),
      ),
    );
  }
}

class AppScreen extends StatelessWidget {
  final StatefulNavigationShell _navigationShell;

  const new({super.key, required this._navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(primary: false, body: _navigationShell);
  }
}
