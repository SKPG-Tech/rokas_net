import "package:flutter/foundation.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";

import "../models/page.dart";
import "../models/tab.dart";

class TabProvider with ChangeNotifier {
  final _tabs = Tabs();
  Tab? _tab;

  TabProvider();

  Tabs get tabs => _tabs;
  Tab? get tab => _tab;
  int? get tabIndex {
    try {
      return _tabs.indexed.firstWhere((e) => identical(e.$2, _tab)).$1;
    } on StateError {
      return null;
    }
  }

  bool get canGoBackward => _tab != null && _tab!.backwardHistory.isNotEmpty;
  bool get canGoForward => _tab != null && _tab!.forwardHistory.isNotEmpty;

  void selectTab(int index) {
    _tab = _tabs.elementAt(index);
    notifyListeners();
  }

  void closeTab(Tab tab) {
    var previousIndex = tabIndex;
    final selectedRemoved = identical(_tab, tab);

    _tabs.remove(tab);
    _refreshTabState();

    if (_tabs.isEmpty) {
      _tab = null;
    } else if (previousIndex! >= _tabs.length) {
      _tab = _tabs.elementAt((previousIndex - 1).clamp(0, _tabs.length));
    } else if (selectedRemoved) {
      _tab = _tabs.elementAt(previousIndex);
    }

    notifyListeners();
  }

  void openNewTab({WebUri? url}) {
    _tabs.addFirst(Tab(url: url));
    if (_tabs.length == 1) _tab = _tabs.single;
    _refreshTabState();
    if (!_tab!.isActive) _tab = _tabs.lastWhere((tab) => tab.isActive);
    notifyListeners();
  }

  void navigateTab(WebUri url, {bool shouldSave = false}) {
    if (_tab == null) {
      openNewTab(url: url);
      return;
    }

    if (_tab!.url != null && shouldSave) {
      _tab!.backwardHistory.push(Page(url: _tab!.url));
      _tab!.forwardHistory.clear();
    }
    _tab!.url = url;
    _tab!.lastUsage = .now();
    notifyListeners();
  }

  void goForward() {
    _tab!.backwardHistory.push(Page(url: _tab!.url));
    _tab!.url = _tab!.forwardHistory.pop().url;
    notifyListeners();
  }

  void goBackward() {
    _tab!.forwardHistory.push(Page(url: _tab!.url));
    _tab!.url = _tab!.backwardHistory.pop().url;
    notifyListeners();
  }

  void _refreshTabState() {
    if (_tabs.isEmpty) return;

    bool isActive(Tab tab) => tab.isActive;
    for (final tab in _tabs) tab.isActive = true;

    for (var count = _tabs.length - 5; count > 0; count--) {
      var lruTab = _tabs.firstWhere(isActive);
      for (final tab in _tabs.where(isActive)) {
        if (tab.lastUsage.isBefore(lruTab.lastUsage)) lruTab = tab;
      }
      lruTab.isActive = false;
    }
  }
}
