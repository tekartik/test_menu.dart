library tekartik_test_menu;

import 'dart:async';

import 'package:func/func.dart';

import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'src/test_menu/declarer.dart';

///
/// The declarer class handling the logic
///
Declarer __declarer;

Declarer get _declarer {
  if (__declarer == null) {
    __declarer = new Declarer();
    scheduleMicrotask(() {
      // An automatic microtask is run after the menu is declarer
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

///
/// Declare function called when we enter a menu
///
void enter(Func0 body) {
  _declarer.enter(body);
}

///
/// Declare function called when we leave a menu
///
void leave(Func0 body) {
  _declarer.leave(body);
}

@deprecated
void solo_item(String name, Func0 body, {String cmd}) {
  _declarer.item(name, body, cmd: cmd, solo: true);
}

void write(Object message) {
  testMenuPresenter.write(message);
  //testMenuManager.write(message);
}

Future<String> prompt([Object message]) {
  //return testMenuManager.prompt(message);
  return testMenuPresenter.prompt(message);
}

//
// run the last declared menu/items
//
Future testMenuRun() async {
  if (_declarer != null) {
    await _declarer.run();
    __declarer = null;
  }
}
