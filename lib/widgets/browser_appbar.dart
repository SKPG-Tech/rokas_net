import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart";

const Size _kAppBarSize = .fromHeight(67);

class BrowserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Uri? initialUri;

  final VoidCallback? onBackwardPressed;
  final VoidCallback? onForwardPressed;
  final ValueChanged<String>? onUriSubmitted;

  final TextEditingController _urlController;

  BrowserAppBar({
    super.key,
    this.initialUri,
    required this.onBackwardPressed,
    required this.onForwardPressed,
    required this.onUriSubmitted,
  }) : _urlController = .new(text: initialUri?.toString());

  @override
  Size get preferredSize => _kAppBarSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final scaffoldState = Scaffold.of(context);

    return AppBar(
      toolbarHeight: _kAppBarSize.height,
      backgroundColor: colorScheme.surfaceContainer,
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      actions: [
        IconButton(
          icon: const Icon(Symbols.arrow_left_alt_rounded),
          onPressed: onBackwardPressed,
        ),
        IconButton(
          icon: const Icon(Symbols.arrow_right_alt_rounded),
          onPressed: onForwardPressed,
        ),
        IconButton(
          icon: const Icon(Symbols.menu),
          onPressed: () => scaffoldState.openEndDrawer(),
        ),
      ],
      titleSpacing: 4,
      actionsPadding: const .only(right: 10),
      title: TextField(
        controller: _urlController,
        decoration: const InputDecoration(
          border: ShapedInputBorder(
            borderSide: .none,
            shape: RoundedRectangleBorder(borderRadius: .all(.circular(100))),
          ),
          filled: true,
        ),
        onSubmitted: onUriSubmitted,
      ),
    );
  }
}
