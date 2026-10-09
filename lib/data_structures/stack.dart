import "dart:collection";

class Stack<T> extends Iterable<T> {
  final Queue<T> _deque = .new();
  int _modificationCount = 0;

  void push(T value) {
    _deque.addLast(value);
    _modificationCount++;
  }

  T pop() {
    if (_deque.isEmpty) throw StateError("Stack is empty");
    _modificationCount++;
    return _deque.removeLast();
  }

  T get top {
    if (_deque.isEmpty) throw StateError("Stack is empty");
    return _deque.last;
  }

  void clear() {
    _deque.clear();
    _modificationCount++;
  }

  @override
  bool get isEmpty => _deque.isEmpty;
  @override
  bool get isNotEmpty => _deque.isNotEmpty;
  @override
  int get length => _deque.length;

  @override
  Iterator<T> get iterator => _StackIterator<T>(this);
}

class _StackIterator<T> implements Iterator<T> {
  final Stack<T> _stack;
  final int _modificationCount;
  int _index;
  T? _current;

  _StackIterator(Stack<T> stack)
    : _stack = stack,
      _modificationCount = stack._modificationCount,
      _index = stack._deque.length;

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    if (_modificationCount != _stack._modificationCount) {
      throw ConcurrentModificationError(_stack);
    }
    _index--;
    if (_index >= 0) {
      _current = _stack._deque.elementAt(_index);
      return true;
    }
    _current = null;
    return false;
  }
}
