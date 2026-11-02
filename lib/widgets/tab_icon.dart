import "package:cached_network_image/cached_network_image.dart";
import "package:material_ui/material_ui.dart" hide Page;

import "../models/page.dart";

const Icon _icon = Icon(Icons.tab);

class TabIcon extends StatelessWidget {
  final Page page;

  const TabIcon({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    if (page.favicon == null) return _icon;
    return CachedNetworkImage(
      imageUrl: page.favicon!,
      height: 24,
      width: 24,
      fadeInDuration: const .new(milliseconds: 300),
      placeholder: (_, _) => _icon,
      errorWidget: (_, _, _) => _icon,
    );
  }
}
