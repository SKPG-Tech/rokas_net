import "../data_structures/singly_linked_list.dart";
import "page.dart";

typedef History = SinglyLinkedList<HistoryEntry>;

final class HistoryEntry extends Page with SinglyLinkedNode<HistoryEntry> {
  final DateTime dateTime;

  HistoryEntry({required super.uri}) : dateTime = .now();
}
