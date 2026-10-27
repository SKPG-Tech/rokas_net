import "dart:convert";

import "package:material_ui/material_ui.dart" hide Page;

import "../models/page.dart";

class TabIcon extends StatelessWidget {
  final Page page;

  const TabIcon({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return page.favicon != null
        ? ImageIcon(MemoryImage(base64Decode(page.favicon!)))
        : const Icon(Icons.tab);
  }
}
