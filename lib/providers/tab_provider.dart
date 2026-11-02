import "package:flutter/foundation.dart";

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

  void openNewTab({Uri? uri}) {
    _tabs.addFirst(Tab(uri: uri));
    if (_tabs.length == 1) _tab = _tabs.single;
    _refreshTabState();
    if (!_tab!.isActive) _tab = _tabs.lastWhere((tab) => tab.isActive);
    notifyListeners();
  }

  void navigateTab(Uri uri) {
    if (_tab == null) {
      openNewTab(uri: uri);
      return;
    }

    if (_tab!.uri != null) {
      _tab!.backwardHistory.push(Page(uri: _tab!.uri));
    }
    _tab!.forwardHistory.clear();
    _tab!.uri = uri;
    notifyListeners();
  }

  void goForward() {
    _tab!.backwardHistory.push(Page(uri: _tab!.uri));
    _tab!.uri = _tab!.forwardHistory.pop().uri;
    notifyListeners();
  }

  void goBackward() {
    _tab!.forwardHistory.push(Page(uri: _tab!.uri));
    _tab!.uri = _tab!.backwardHistory.pop().uri;
    notifyListeners();
  }

  VoidCallback? get forwardHandler {
    if (_tab == null || _tab!.forwardHistory.isEmpty) return null;
    return goForward;
  }

  VoidCallback? get backwardHandler {
    if (_tab == null || _tab!.backwardHistory.isEmpty) return null;
    return goBackward;
  }

  void _refreshTabState() {
    for (final (index, tab) in _tabs.indexed) tab.isActive = index < 5;
  }
}
