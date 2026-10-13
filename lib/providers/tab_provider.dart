import "package:flutter/foundation.dart";

import "../models/page.dart";
import "../models/tab.dart";

class TabProvider with ChangeNotifier {
  final _tabs = Tabs();
  int? _selectedTab;

  TabProvider();

  Tabs get tabs => _tabs;
  int? get selectedTab => _selectedTab;
  Tab? get tab => _selectedTab != null ? _tabs.elementAt(_selectedTab!) : null;

  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void closeTab(Tab tab) {
    final tabToRemove = _tabs.indexed.firstWhere((e) => identical(e.$2, tab));
    _tabs.remove(tab);
    if (_tabs.isEmpty) {
      _selectedTab = null;
    } else {
      if (tabToRemove.$1 < _selectedTab!) {
        _selectedTab = _selectedTab! - 1;
      } else if (tabToRemove.$1 >= _selectedTab!) {
        _selectedTab = _selectedTab!.clamp(0, _tabs.length - 1);
      }
    }

    notifyListeners();
  }

  void openNewTab({required Uri uri}) {
    _tabs.add(Tab(uri: uri));
    _selectedTab = (_selectedTab ?? -1) + 1;
    notifyListeners();
  }

  void navigateTab(Uri uri) {
    final tab = _tabs.elementAt(_selectedTab!);
    tab.backwardHistory.push(Page(uri: tab.uri));
    tab.forwardHistory.clear();
    tab.uri = uri;
    notifyListeners();
  }

  void goForward() {
    final tab = _tabs.elementAt(_selectedTab!);
    tab.backwardHistory.push(Page(uri: tab.uri));
    tab.uri = tab.forwardHistory.pop().uri;
    notifyListeners();
  }

  void goBackward() {
    final tab = _tabs.elementAt(_selectedTab!);
    tab.forwardHistory.push(Page(uri: tab.uri));
    tab.uri = tab.backwardHistory.pop().uri;
    notifyListeners();
  }

  void Function()? get forwardHandler {
    if (_selectedTab == null || tab!.forwardHistory.isEmpty) return null;
    return goForward;
  }

  void Function()? get backwardHandler {
    if (_selectedTab == null || tab!.backwardHistory.isEmpty) return null;
    return goBackward;
  }
}
