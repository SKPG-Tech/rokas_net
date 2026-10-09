abstract base mixin class SinglyLinkedNode<T extends SinglyLinkedNode<T>> {
  SinglyLinkedList<T>? _list;
  T? _next;

  SinglyLinkedList<T>? get list => _list;

  void unlink() {
    _list!._unlink(this as T);
  }

  T? get next {
    if (_list == null) return null;
    return _next;
  }

  void insertAfter(T entry) {
    _list!._insertAfter(this as T, entry);
  }

  void insertBefore(T entry) {
    _list!._insertBefore(this as T, entry);
  }
}

base class SinglyLinkedList<T extends SinglyLinkedNode<T>> extends Iterable<T> {
  int _length = 0;
  int _modificationCount = 0;
  T? _first;
  T? _last;

  SinglyLinkedList();

  void add(T entry) => addLast(entry);

  void addFirst(T entry) {
    _insertBefore(_first, entry);
  }

  void addLast(T entry) {
    _insertAfter(_last, entry);
  }

  void addAll(Iterable<T> entries) {
    entries.forEach(addLast);
  }

  bool remove(T entry) {
    if (entry._list != this) return false;
    _unlink(entry);
    return true;
  }

  @override
  bool contains(Object? element) =>
      element is SinglyLinkedNode && identical(this, element.list);

  @override
  Iterator<T> get iterator => _SinglyLinkedIterator<T>(this);

  @override
  int get length => _length;

  void clear() {
    if (isEmpty) return;
    _modificationCount++;

    var current = _first;
    while (current != null) {
      var temp = current;
      current = temp._next;
      temp._next = temp._list = null;
    }

    _first = _last = null;
    _length = 0;
  }

  @override
  T get first {
    if (isEmpty) {
      throw StateError("No such element");
    }
    return _first!;
  }

  @override
  T get last {
    if (isEmpty) {
      throw StateError("No such element");
    }
    return _last!;
  }

  @override
  T get single {
    if (isEmpty) {
      throw StateError("No such element");
    }
    if (_length > 1) {
      throw StateError("Too many elements");
    }
    return _first!;
  }

  @override
  void forEach(void Function(T entry) action) {
    if (isEmpty) return;
    var modificationCount = _modificationCount;

    var current = _first;
    while (current != null) {
      action(current);
      if (modificationCount != _modificationCount) {
        throw ConcurrentModificationError(this);
      }
      current = current._next;
    }
  }

  @override
  bool get isEmpty => _length == 0;

  void _insertBefore(T? entry, T newEntry) {
    if (newEntry.list != null) {
      throw StateError("SinglyLinkedNode is already in a SinglyLinkedList");
    }
    if (entry != null && entry._list != this) {
      throw ArgumentError("Target entry is not in this list");
    }

    _modificationCount++;
    newEntry._list = this;

    if (isEmpty) {
      assert(entry == null);
      _first = _last = newEntry;
      _length++;
      return;
    }

    if (identical(entry, _first)) {
      newEntry._next = entry;
      _first = newEntry;
    } else {
      var current = _first!;
      while (current._next != null && !identical(current._next, entry))
        current = current._next!;

      newEntry._next = current._next;
      current._next = newEntry;
    }
    _length++;
  }

  void _insertAfter(T? entry, T newEntry) {
    if (newEntry.list != null) {
      throw StateError("SinglyLinkedNode is already in a SinglyLinkedList");
    }
    if (entry != null && entry._list != this) {
      throw ArgumentError("Target entry is not in this list");
    }

    _modificationCount++;
    newEntry._list = this;

    if (isEmpty) {
      assert(entry == null);
      _first = _last = newEntry;
      _length++;
      return;
    }

    if (identical(entry, _last)) {
      _last!._next = newEntry;
      _last = newEntry;
    } else {
      var current = _first!;
      while (current._next != null && !identical(current, entry))
        current = current._next!;

      newEntry._next = current._next;
      current._next = newEntry;
    }
    _length++;
  }

  void _unlink(T entry) {
    _modificationCount++;
    entry._list = null;

    if (_length == 1) {
      _first = _last = null;
    } else if (identical(entry, _first)) {
      _first = entry._next;
    } else {
      var current = _first!;
      while (current._next != null && !identical(current._next, entry))
        current = current._next!;

      current._next = entry._next;
      if (identical(entry, _last)) {
        _last = current;
      }
    }

    _length--;
    entry._next = null;
  }
}

class _SinglyLinkedIterator<T extends SinglyLinkedNode<T>>
    implements Iterator<T> {
  final SinglyLinkedList<T> _list;
  final int _modificationCount;
  T? _current;
  T? _next;

  _SinglyLinkedIterator(SinglyLinkedList<T> list)
    : _list = list,
      _modificationCount = list._modificationCount,
      _next = list._first;

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    if (_modificationCount != _list._modificationCount) {
      throw ConcurrentModificationError(_list);
    }
    if (_list.isEmpty || _next == null) {
      _current = null;
      return false;
    }
    _current = _next;
    _next = _next!._next;
    return true;
  }
}
