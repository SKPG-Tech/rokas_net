import "../data_structures/doubly_linked_list.dart";
import "../data_structures/stack.dart";
import "page.dart";

typedef Tabs = DoublyLinkedList<Tab>;

final class Tab extends Page with DoublyLinkedNode<Tab> {
  final forwardHistory = Stack<Page>();
  final backwardHistory = Stack<Page>();
  bool active;

  Tab({required super.uri, super.title, super.favicon, bool? isActive})
    : active = isActive ?? true;

  factory Tab.fromPage(Page page) =>
      Tab(uri: page.uri, title: page.title, favicon: page.favicon);

  void toggleActivation() => active = !active;
}
