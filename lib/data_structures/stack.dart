import "dart:collection";

class Stack<T> {
  final Queue<T> _deque = ListQueue<T>();

  void push(T value) => _deque.addLast(value);

  T pop() {
    if (_deque.isEmpty) throw StateError("Stack is empty");
    return _deque.removeLast();
  }

  T get top {
    if (_deque.isEmpty) throw StateError("Stack is empty");
    return _deque.last;
  }

  bool get isEmpty => _deque.isEmpty;
  int get length => _deque.length;
}
