import "dart:io";

import "package:flutter/foundation.dart";
import "package:webview_flutter/webview_flutter.dart";
import "package:webview_flutter_windows/webview_flutter_windows.dart";

abstract class _PlatformInterface<T> {
  Future<void> initialize();
  void dispose();

  void navigateTo(Uri uri);

  T getWebviewController();
}

class CrossplatformWebviewController
    with ChangeNotifier
    implements _PlatformInterface {
  final _PlatformInterface _controller;

  CrossplatformWebviewController({
    required ValueGetter<NavigationDelegate> delegate,
  }) : _controller = !Platform.isWindows
           ? _MobileController(delegate)
           : _DesktopController();

  @override
  dynamic getWebviewController() => _controller.getWebviewController();

  @override
  Future<void> initialize() async {
    await _controller.initialize();
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void navigateTo(Uri uri) {
    _controller.navigateTo(uri);
    notifyListeners();
  }
}

class _MobileController implements _PlatformInterface<WebViewController> {
  final _controller = WebViewController();
  final ValueGetter<NavigationDelegate> delegateReceiver;

  _MobileController(this.delegateReceiver);

  @override
  WebViewController getWebviewController() => _controller;

  @override
  Future<void> initialize() async {
    await _controller.setJavaScriptMode(.unrestricted);
    await _controller.setNavigationDelegate(delegateReceiver());
  }

  @override
  void dispose() {}

  @override
  void navigateTo(Uri uri) => _controller.loadRequest(uri);
}

class _DesktopController implements _PlatformInterface<WebviewController> {
  final _controller = WebviewController();

  @override
  WebviewController getWebviewController() => _controller;

  @override
  Future<void> initialize() async {
    await _controller.initialize();
    await _controller.setPopupWindowPolicy(.deny);
    await _controller.setDefaultContextMenusEnabled(true);
  }

  @override
  void dispose() => _controller.dispose();

  @override
  void navigateTo(Uri uri) => _controller.loadUrl(uri.toString());
}
