part of tekartik_test_menu;

abstract class TestItem {
  String get cmd;
  String get name;
  factory TestItem.fn(String name, TestItemFn fn, {String cmd, bool solo}) {
    return new RunnableTestItem(name, fn, cmd: cmd, solo: solo);
  }
  factory TestItem.menu(TestMenu menu) {
    return new MenuTestItem(menu);
  }
  // can be void or future
  dynamic run();
}

typedef R TestItemFn<R>();

abstract class _BaseTestItem {
  String name;
  String get cmd;
  _BaseTestItem(this.name);

  @override
  String toString() {
    return name;
  }
}

class RunnableTestItem extends _BaseTestItem implements TestItem {
  TestItemFn fn;
  String cmd;
  bool solo;
  RunnableTestItem(String name, this.fn, {this.cmd, this.solo}) : super(name);

  run() {
    return fn();
  }
}

class MenuTestItem extends _BaseTestItem implements TestItem {
  TestMenu menu;
  String get cmd => menu.cmd;
  MenuTestItem(this.menu) : super(null) {
    name = menu.name;
  }

  void run() {
    testMenuManager.push(menu);
  }

  @override
  String toString() {
    return 'menu ${super.toString()}';
  }
}

class TestMenu {
  String cmd;
  String name;
  List<TestItem> _items = [];
  Iterable<TestItem> get items => _items;
  int get length => _items.length;
  TestMenu(this.name, {this.cmd});
  void add(String name, TestItemFn fn) => addItem(new TestItem.fn(name, fn));
  void addMenu(TestMenu menu) => addItem(new TestItem.menu(menu));
  void addItem(TestItem item) => _items.add(item);
  void addAll(List<TestItem> items) => items.forEach((TestItem item) {
        addItem(item);
      });
  TestItem operator [](int index) => _items[index];
  TestItem byCmd(String cmd) {
    for (TestItem item in _items) {
      if (item.cmd == cmd) {
        return item;
      }
    }
    int value = int.parse(cmd, onError: (String textValue) {
      return -1;
    });

    if (value != null && (value >= 0 && value < length)) {
      return _items[value];
    }
    return null;
  }

  @override
  String toString() {
    return "test menu '$name'";
  }

  int indexOfItem(TestItem item) {
    return _items.indexOf(item);
  }

  int indexOfMenu(TestMenu menu) {
    for (int i = 0; i < _items.length; i++) {
      TestItem item = _items[i];
      if (item is MenuTestItem) {
        if (item.menu == menu) {
          return i;
        }
      }
    }
    return -1;
  }
}
