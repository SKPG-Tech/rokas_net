import "package:material_symbols_icons/symbols.dart";
import "package:material_ui/material_ui.dart" hide Tab;
import "package:provider/provider.dart";

import "../models/tab.dart";
import "../providers/tab_provider.dart";
import "../utils/haptics.dart";

const Size _kAppBarSize = .fromHeight(67);
const double _kSwipeThreshold = 100;

enum _SwipeDirection { left, right }

class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Tab? tab;

  final VoidCallback? onBackwardPressed;
  final VoidCallback? onForwardPressed;
  final ValueChanged<String> onUrlSubmitted;

  late final TextEditingController _urlController;

  BrowserAppBar({
    super.key,
    this.tab,
    required this.onBackwardPressed,
    required this.onForwardPressed,
    required this.onUrlSubmitted,
  }) : _urlController = .new(text: tab?.url?.toString());

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
  bool _popped = false;

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

    final scaffoldState = Scaffold.of(context);
    final tabProvider = context.read<TabProvider>();

    final offset = _dragOffset.dx.abs();
    final swipeDirection = _dragOffset.dx.sign == -1
        ? _SwipeDirection.left
        : _SwipeDirection.right;
    final pastThreshold = offset > _kSwipeThreshold;

    bool tabAvailable(_SwipeDirection direction) {
      if (tabProvider.tab == null) return false;
      return switch (direction) {
        .right =>
          swipeDirection == .right &&
              tabProvider.tab!.next != null &&
              tabProvider.tab!.next!.isActive,
        .left =>
          swipeDirection == .left &&
              tabProvider.tab!.previous != null &&
              tabProvider.tab!.previous!.isActive,
      };
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        if (_animController.isAnimating) _animController.stop();
        var popped = _popped && pastThreshold;
        if (pastThreshold && !_popped) {
          await HapticFeedback.play(.tick);
          popped = true;
        }
        setState(() {
          _dragOffset += details.delta;
          _popped = popped;
        });
      },
      onHorizontalDragEnd: (details) {
        if (pastThreshold) {
          final tab = tabProvider.tab;
          final tabs = tabProvider.tabs.indexed;
          if (tabAvailable(.right)) {
            tabProvider.selectTab(
              tabs.firstWhere((e) => identical(e.$2, tab?.next)).$1,
            );
            HapticFeedback.play(.spin);
          } else if (tabAvailable(.left)) {
            tabProvider.selectTab(
              tabs.firstWhere((e) => identical(e.$2, tab?.previous)).$1,
            );
            HapticFeedback.play(.spin);
          }
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
              child: AnimatedSlide(
                offset: !pastThreshold ? _dragOffset / 400 : .zero,
                duration: _animController.duration!,
                curve: Curves.easeOutExpo,
                child: Text(switch (swipeDirection) {
                  .right => tabAvailable(.right) ? "Previous tab" : "No tab",
                  .left => tabAvailable(.left) ? "Next tab" : "No tab",
                }, style: .new(fontWeight: pastThreshold ? .w600 : .normal)),
              ),
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
                enabled: widget.tab != null,
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
