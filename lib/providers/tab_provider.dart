import "package:flutter/foundation.dart";

import "../models/page.dart";
import "../models/tab.dart";

class TabProvider with ChangeNotifier {
  final _tabs = Tabs();
  Tab? _tab;
  int? _tabIndex;

  TabProvider();

  Tabs get tabs => _tabs;
  Tab? get tab => _tab;
  int? get tabIndex => _tabIndex;

  void selectTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void closeTab(Tab tab) {
    final tabToRemove = _tabs.indexed.firstWhere((e) => identical(e.$2, tab));
    _tabs.remove(tab);
    if (_tabs.isEmpty) {
      _tab = null;
      _tabIndex = null;
    } else {
      if (tabToRemove.$1 < tabIndex!) {
        _tabIndex = _tabIndex! - 1;
        _tab = _tabs.elementAt(_tabIndex!);
      } else if (tabToRemove.$1 >= tabIndex!) {
        _tabIndex = tabIndex!.clamp(0, _tabs.length - 1);
        _tab = _tabs.elementAt(_tabIndex!);
      }
    }

    notifyListeners();
  }

  void openNewTab({Uri? uri}) {
    _tabs.add(Tab(uri: uri));
    _tabIndex = (_tabIndex ?? -1) + 1;
    _tab = _tabs.elementAt(_tabIndex!);
    notifyListeners();
  }

  void navigateTab(Uri uri) {
    if (_tab == null) {
      openNewTab(uri: uri);
      return;
    }

    _tab!.backwardHistory.push(Page(uri: _tab!.uri));
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
}
