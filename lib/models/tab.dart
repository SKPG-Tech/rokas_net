import "../data_structures/doubly_linked_list.dart";
import "../data_structures/stack.dart";
import "page.dart";

typedef Tabs = DoublyLinkedList<Tab>;

final class Tab extends Page with DoublyLinkedNode<Tab> {
  final forwardHistory = Stack<Page>();
  final backwardHistory = Stack<Page>();
  bool isActive;

  Tab({super.url, super.title, bool? isActive}) : isActive = isActive ?? true;
}
