library tekartik_test_menu;

import 'dart:async';
import 'package:func/func.dart';

import 'src/test_menu/declarer.dart';
import 'src/common.dart';

part 'src/test_menu/test_menu.dart';

part 'src/test_menu/test_menu_manager.dart';

bool debugTestMenuManager = false;

void showTestMenu(TestMenu menu) {
  testMenuManager.push(menu);
}

///
/// The declarer class handling the logic
///
Declarer __declarer;

Declarer get _declarer {
  if (__declarer == null) {
    __declarer = new Declarer();
    scheduleMicrotask(() {
      testMenuRun();
    });
  }
  return __declarer;
}

///
/// Declare a menu
///
/// declaration must be sync
///
void menu(String name, VoidFunc0 body) {
  _declarer.menu(name, body);
}

///
/// Declare a menu item
///
/// can return a future
void item(String name, Func0 body) {
  _declarer.item(name, body);
}

void write(Object message) {
  testMenuManager.write(message);
}

Future<String> prompt([Object message]) {
  return testMenuManager.prompt(message);
}

testMenuRun() {
  if (_declarer != null) {
    _declarer.run();
    __declarer = null;
  }
}