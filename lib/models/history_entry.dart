import "../data_structures/singly_linked_list.dart";
import "page.dart";

typedef History = SinglyLinkedList<HistoryEntry>;

final class HistoryEntry extends Page with SinglyLinkedNode<HistoryEntry> {
  final DateTime dateTime;

  HistoryEntry({DateTime? dateTime, required super.url, super.title})
    : dateTime = dateTime ?? .now();

  @override
  Map<String, dynamic> toJson() => {
    "date_time": dateTime.toString(),
    ...super.toJson(),
  };

  HistoryEntry.fromJson(super.json)
    : dateTime = .parse(json["date_time"]),
      super.fromJson();
}
