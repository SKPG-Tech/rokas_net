import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../providers/tab_provider.dart";

const Size _kAppBarSize = .fromHeight(67);
const double _kSwipeThreshold = 100;

enum _SwipeDirection { left, right }

class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Uri? initialUrl;

  final VoidCallback? onBackwardPressed;
  final VoidCallback? onForwardPressed;
  final ValueChanged<String>? onUrlSubmitted;

  late final TextEditingController _urlController;

  BrowserAppBar({
    super.key,
    this.initialUrl,
    required this.onBackwardPressed,
    required this.onForwardPressed,
    required this.onUrlSubmitted,
  }) : _urlController = .new(text: initialUrl?.toString());

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();

  @override
  Size get preferredSize => _kAppBarSize;
}

class _BrowserAppBarState extends State<BrowserAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Offset _dragOffset = .zero;
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const .new(milliseconds: 300),
    );
    _animController.addListener(() {
      if (_animation == null) return;
      setState(() => _dragOffset = _animation!.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final scaffoldState = Scaffold.of(context);
    final tabProvider = context.read<TabProvider>();

    final offset = _dragOffset.dx.abs();
    final swipeDirection = _dragOffset.dx.sign == -1
        ? _SwipeDirection.left
        : _SwipeDirection.right;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_animController.isAnimating) _animController.stop();
        setState(() => _dragOffset += details.delta);
      },
      onHorizontalDragEnd: (details) {
        if (offset > _kSwipeThreshold) {
          final tab = tabProvider.tab;
          final tabs = tabProvider.tabs.indexed;
          var index = tabProvider.tabIndex;
          if (swipeDirection == .right && tab?.next != null) {
            index = tabs.firstWhere((e) => identical(e.$2, tab?.next)).$1;
          } else if (swipeDirection == .left && tab?.previous != null) {
            index = tabs.firstWhere((e) => identical(e.$2, tab?.previous)).$1;
          }
          if (index != null) tabProvider.selectTab(index);
        }

        _animation = Tween<Offset>(begin: _dragOffset, end: .zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutExpo),
        );
        _animController.forward(from: 0.0);
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              alignment: switch (swipeDirection) {
                .right => .bottomLeft,
                .left => .bottomRight,
              },
              padding: .symmetric(
                vertical: _kAppBarSize.height / 3,
                horizontal: 15,
              ),
              color: colorScheme.surfaceContainer,
              child: Text(switch (swipeDirection) {
                .right => "Previous tab",
                .left => "Next tab",
              }),
            ),
          ),
          Transform.translate(
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
                controller: widget._urlController,
                keyboardType: .url,
                decoration: const InputDecoration(
                  border: ShapedInputBorder(
                    borderSide: .none,
                    shape: RoundedRectangleBorder(
                      borderRadius: .all(.circular(100)),
                    ),
                  ),
                  filled: true,
                ),
                onSubmitted: widget.onUrlSubmitted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
