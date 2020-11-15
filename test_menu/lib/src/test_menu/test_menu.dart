import 'dart:async';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

abstract class WithParent {
  TestMenu get parent;
  set parent(TestMenu parent);
}

class _WithParentMixin implements WithParent {
  @override
  TestMenu parent;
}

abstract class TestItem implements Runnable, WithParent {
  String get cmd;
  String get name;
  factory TestItem.fn(String name, TestItemFn fn,
      {String cmd, bool solo, bool test}) {
    return RunnableTestItem(name, fn, cmd: cmd, solo: solo, test: test);
  }
  factory TestItem.menu(TestMenu menu) {
    return MenuTestItem(menu);
  }
}

typedef TestItemFn<R> = R Function();

typedef TestCommandFn<R> = R Function(String command);

abstract class _BaseTestItem {
  final bool solo;
  String name;
  String get cmd;
  _BaseTestItem(this.name, this.solo);

  @override
  String toString() {
    return name;
  }
}

abstract class Runnable {
  dynamic run();
}

class _RunnableMixin implements Runnable {
  TestItemFn fn;
  @override
  dynamic run() {
    return fn();
  }
}

class MenuEnter extends Object with _RunnableMixin, _WithParentMixin {
  MenuEnter(TestItemFn fn) {
    this.fn = fn;
  }

  @override
  String toString() {
    return 'enter';
  }
}

// Unhandled command (?, ., -)
class MenuCommand extends Object with _WithParentMixin {
  final TestCommandFn fn;
  MenuCommand(this.fn);

  @override
  String toString() {
    return 'command';
  }
}

class MenuLeave extends Object with _RunnableMixin, _WithParentMixin {
  MenuLeave(TestItemFn fn) {
    this.fn = fn;
  }

  @override
  String toString() {
    return 'leave';
  }
}

class RunnableTestItem extends _BaseTestItem
    with _RunnableMixin, _WithParentMixin
    implements TestItem {
  @override
  String cmd;
  final bool test;
  RunnableTestItem(String name, TestItemFn fn, {this.cmd, this.test, bool solo})
      : super(name, solo) {
    this.fn = fn;
  }
}

class MenuTestItem extends _BaseTestItem
    with _WithParentMixin
    implements TestItem {
  TestMenu menu;
  @override
  String get cmd => menu.cmd;
  MenuTestItem(this.menu) : super(null, menu.solo) {
    name = menu.name;
  }

  @override
  Future run() async {
    await testMenuManager.pushMenu(menu);
  }

  @override
  String toString() {
    return 'menu ${super.toString()}';
  }
}

class RootTestMenu extends TestMenu {
  RootTestMenu() : super(null);
}

abstract class TestObject {}

class TestMenu extends Object with _WithParentMixin implements TestObject {
  String cmd;
  String name;
  final bool group;
  final bool solo;
  final _items = <TestItem>[];
  List<TestItem> get items => _items;
  int get length => _items.length;
  TestMenu(this.name, {this.cmd, this.group, this.solo});
  final _enters = <MenuEnter>[];
  final _leaves = <MenuLeave>[];
  MenuCommand _command;
  Iterable<MenuEnter> get enters => _enters;
  Iterable<MenuLeave> get leaves => _leaves;

  /// The default command handlers.
  MenuCommand get command => _command;

  void add(String name, TestItemFn fn) => addItem(TestItem.fn(name, fn));
  void fixParent(WithParent child) {
    child.parent = this;
  }

  void addEnter(MenuEnter menuEnter) {
    fixParent(menuEnter);
    _enters.add(menuEnter);
  }

  void addLeave(MenuLeave menuLeave) {
    fixParent(menuLeave);
    _leaves.add(menuLeave);
  }

  void addMenu(TestMenu menu) {
    fixParent(menu);
    addItem(TestItem.menu(menu));
  }

  void addItem(TestItem item) {
    fixParent(item);
    _items.add(item);
  }

  void setCommand(MenuCommand menuCommand) {
    fixParent(menuCommand);
    _command = menuCommand;
  }

  void addAll(List<TestItem> items) => items.forEach((TestItem item) {
        addItem(item);
      });
  TestItem operator [](int index) => _items[index];
  TestItem byCmd(String cmd) {
    for (final item in _items) {
      if (item.cmd == cmd) {
        return item;
      }
    }
    final value = int.tryParse(cmd) ?? -1;

    if (value != null && (value >= 0 && value < length)) {
      return _items[value];
    }
    return null;
  }

  @override
  String toString() {
    return "tm'$name'";
  }

  int indexOfItem(TestItem item) {
    return _items.indexOf(item);
  }

  int indexOfMenu(TestMenu menu) {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item is MenuTestItem) {
        if (item.menu == menu) {
          return i;
        }
      }
    }
    return -1;
  }
}
