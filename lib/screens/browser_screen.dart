import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../routes.dart";

class BrowserScreen extends StatefulWidget {
  final int? tab;

  const new({super.key, this.tab});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.tab == null
        ? const _NewTabView()
        : _TabView(tab: widget.tab!);
  }
}

class _NewTabView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.goBrowser(tab: 100),
      child: const Text("Press me"),
    );
  }
}

class _TabView extends StatelessWidget {
  final int _tab;

  const new({required this._tab});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.pop(),
      child: Text(_tab.toString()),
    );
  }
}
