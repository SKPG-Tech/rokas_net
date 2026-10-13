import "dart:io";

import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";
import "package:webview_flutter_windows/webview_flutter_windows.dart";

import "../controllers/crossplatform_webview_controller.dart";

class CrossplatformWebview extends StatefulWidget {
  final CrossplatformWebviewController controller;

  const CrossplatformWebview({super.key, required this.controller});

  @override
  State<CrossplatformWebview> createState() => _CrossplatformWebviewState();
}

class _CrossplatformWebviewState extends State<CrossplatformWebview> {
  final _isWindows = Platform.isWindows;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    //widget.controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (_, _) {
        if (_isWindows) {
          final webviewController = controller
              .getWebviewController<WebviewController>();
          return webviewController.value.isInitialized
              ? Webview(webviewController)
              : const Center(child: CircularProgressIndicator());
        } else {
          return WebViewWidget(controller: controller.getWebviewController());
        }
      },
    );
  }
}
