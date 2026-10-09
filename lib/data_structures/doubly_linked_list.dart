import "dart:collection";

typedef DoublyLinkedNode<T extends LinkedListEntry<T>> = LinkedListEntry<T>;
typedef DoublyLinkedList<T extends DoublyLinkedNode<T>> = LinkedList<T>;
