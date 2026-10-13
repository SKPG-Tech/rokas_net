import "dart:io";

import "package:flutter/foundation.dart";
import "package:webview_flutter/webview_flutter.dart";
import "package:webview_flutter_windows/webview_flutter_windows.dart";

abstract class _PlatformInterface<T> {
  Future<void> initialize();
  void dispose();

  void navigateTo(Uri uri);

  T get webviewController;
}

class CrossplatformWebviewController with ChangeNotifier {
  final _PlatformInterface _controller;

  CrossplatformWebviewController({
    required ValueGetter<NavigationDelegate> delegate,
  }) : _controller = !Platform.isWindows
           ? _MobileController(delegate)
           : _DesktopController();

  T getWebviewController<T>() => _controller.webviewController as T;

  Future<void> initialize() async {
    await _controller.initialize();
    notifyListeners();
  }

  void disposeController() {
    _controller.dispose();
    notifyListeners();
  }

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
  WebViewController get webviewController => _controller;

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
  WebviewController get webviewController => _controller;

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
