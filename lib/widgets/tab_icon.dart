import "package:cached_network_image/cached_network_image.dart";
import "package:material_ui/material_ui.dart" hide Page;

import "../models/page.dart";

const Icon _icon = Icon(Icons.tab);

class TabIcon extends StatelessWidget {
  final Page page;

  const TabIcon({super.key, required this.page});

  Widget _fallbackIcon(String domain) {
    return CachedNetworkImage(
      imageUrl: "https://www.google.com/s2/favicons?domain=$domain&sz=32",
      height: 24,
      width: 24,
      fadeInDuration: const .new(milliseconds: 300),
      placeholder: (_, _) => _icon,
      errorWidget: (_, _, _) => _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (page.favicon == null && page.url == null) return _icon;
    if (page.favicon == null) return _fallbackIcon(page.url!.host);
    return CachedNetworkImage(
      imageUrl: page.favicon!,
      height: 24,
      width: 24,
      fadeInDuration: const .new(milliseconds: 300),
      placeholder: (_, _) => _icon,
      errorWidget: (_, _, _) => _fallbackIcon(page.url!.host),
    );
  }
}
