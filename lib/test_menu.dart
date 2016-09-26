library tekartik_test_menu;

import 'dart:async';

import 'package:func/func.dart';

import 'src/test_menu/declarer.dart';

part 'src/test_menu/test_menu.dart';

part 'src/test_menu/test_menu_manager.dart';
//import 'src/common.dart';


bool debugTestMenuManager = false;

void showTestMenu(TestMenu menu) {
  if (testMenuManager == null) {
    print(
        'Cannot tell whether you\'re running from io or browser. Please include the proper header');
  }
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

Declarer testMenuNewDeclarer() {
  __declarer = new Declarer();
  return __declarer;
}

///
/// Declare a menu
///
/// declaration must be sync
///
void menu(String name, VoidFunc0 body, {String cmd}) {
  _declarer.menu(name, body, cmd: cmd);
}

///
/// Declare a menu item
///
/// can return a future
///
/// @param cmd command shortcut (instead of incremental number)
void item(String name, Func0 body, {String cmd}) {
  _declarer.item(name, body, cmd: cmd);
}

@deprecated
void solo_item(String name, Func0 body, {String cmd}) {
  _declarer.item(name, body, cmd: cmd, solo: true);
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