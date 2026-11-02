import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../providers/tab_provider.dart";

const Size _kAppBarSize = .fromHeight(67);

class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Uri? initialUri;

  final VoidCallback? onBackwardPressed;
  final VoidCallback? onForwardPressed;
  final ValueChanged<String>? onUriSubmitted;

  final FocusNode urlFieldFocusNode;

  late final TextEditingController _urlController;

  BrowserAppBar({
    super.key,
    this.initialUri,
    required this.urlFieldFocusNode,
    required this.onBackwardPressed,
    required this.onForwardPressed,
    required this.onUriSubmitted,
  }) : _urlController = .new(text: initialUri?.toString());

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();

  @override
  Size get preferredSize => _kAppBarSize;
}

class _BrowserAppBarState extends State<BrowserAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Offset _dragOffset = Offset.zero;
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(() {
      if (_animation == null) return;
      setState(() => _dragOffset = _animation!.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final scaffoldState = Scaffold.of(context);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_animationController.isAnimating) _animationController.stop();
        setState(() => _dragOffset += details.delta);
      },
      onHorizontalDragEnd: (details) {
        final offset = _dragOffset.dx;
        if (offset.abs() > 100) {
          final tabProvider = context.read<TabProvider>();
          final tab = tabProvider.tab;
          final tabs = tabProvider.tabs.indexed;
          var index = tabProvider.tabIndex;
          if (offset.sign == 1 && tab?.previous != null) {
            index = tabs.firstWhere((e) => identical(e.$2, tab?.previous)).$1;
          } else if (offset.sign == -1 && tab?.next != null) {
            index = tabs.firstWhere((e) => identical(e.$2, tab?.next)).$1;
          }
          if (index != null) tabProvider.selectTab(index);
        }

        _animation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOutExpo,
              ),
            );
        _animationController.forward(from: 0.0);
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: AppBar(
          toolbarHeight: _kAppBarSize.height,
          backgroundColor: colorScheme.surfaceContainer,
          actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
          actions: [
            IconButton(
              icon: const Icon(Symbols.arrow_left_alt_rounded),
              onPressed: widget.onBackwardPressed,
            ),
            IconButton(
              icon: const Icon(Symbols.arrow_right_alt_rounded),
              onPressed: widget.onForwardPressed,
            ),
            IconButton(
              icon: const Icon(Symbols.menu),
              onPressed: () => scaffoldState.openEndDrawer(),
            ),
          ],
          titleSpacing: 4,
          actionsPadding: const .only(right: 10),
          title: TextField(
            focusNode: widget.urlFieldFocusNode,
            controller: widget._urlController,
            decoration: const InputDecoration(
              border: ShapedInputBorder(
                borderSide: .none,
                shape: RoundedRectangleBorder(
                  borderRadius: .all(.circular(100)),
                ),
              ),
              filled: true,
            ),
            onSubmitted: widget.onUriSubmitted,
          ),
        ),
      ),
    );
  }
}
