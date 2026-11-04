import "package:flutter_inappwebview/flutter_inappwebview.dart";

class InAppWebviewController {
  InAppWebViewController? _webviewController;

  bool _shouldSave = false;
  set shouldSave(bool value) => _shouldSave = value;
  bool get shouldSave {
    final shouldSave = _shouldSave;
    _shouldSave = false;
    return shouldSave;
  }

  void Function(InAppWebViewController) get onWebViewCreated =>
      (controller) => _webviewController = controller;

  void loadUrl(WebUri url, {bool shouldSave = false}) {
    _webviewController?.loadUrl(urlRequest: .new(url: url));
    _shouldSave = shouldSave;
  }

  Future<Favicon?> getIcon() async =>
      (await _webviewController?.getFavicons())?.firstOrNull;
}
