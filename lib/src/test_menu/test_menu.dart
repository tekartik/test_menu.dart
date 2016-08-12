part of tekartik_test_menu;

abstract class TestItem {
  String get name;
  factory TestItem.fn(String name, TestItemFn fn) {
    return new RunnableTestItem(name, fn);
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
  _BaseTestItem(this.name);

  @override
  String toString() {
    return name;
  }
}

class RunnableTestItem extends _BaseTestItem implements TestItem {
  TestItemFn fn;
  RunnableTestItem(String name, this.fn) : super(name);

  run() {
    return fn();
  }
}

class MenuTestItem extends _BaseTestItem implements TestItem {
  TestMenu menu;

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
  String name;
  List<TestItem> _items = [];
  int get length => _items.length;
  TestMenu(this.name);
  void add(String name, TestItemFn fn) => addItem(new TestItem.fn(name, fn));
  void addMenu(TestMenu menu) => addItem(new TestItem.menu(menu));
  void addItem(TestItem item) => _items.add(item);
  void addAll(List<TestItem> items) => items.forEach((TestItem item) {
        addItem(item);
      });
  TestItem operator [](int index) => _items[index];

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
