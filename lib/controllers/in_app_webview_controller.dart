import "package:flutter_inappwebview/flutter_inappwebview.dart";

class InAppWebviewController {
  InAppWebViewController? _webviewController;

  void Function(InAppWebViewController) get onWebViewCreated =>
      (controller) => _webviewController = controller;

  void loadUrl(WebUri url) =>
      _webviewController?.loadUrl(urlRequest: .new(url: url));

  Future<Favicon?> getIcon() async =>
      (await _webviewController?.getFavicons())?.firstOrNull;
}
