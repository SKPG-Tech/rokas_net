import "package:material_ui/material_ui.dart" hide Page;

import "../models/page.dart";

class TabIcon extends StatelessWidget {
  final Page page;

  const TabIcon({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return page.favicon != null
        ? Image.network(
            height: 24,
            page.favicon!,
            errorBuilder: (_, _, _) => const Icon(Icons.tab),
          )
        : const Icon(Icons.tab);
  }
}
