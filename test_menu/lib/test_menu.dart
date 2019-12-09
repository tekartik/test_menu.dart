library tekartik_test_menu;

import 'dart:async';

import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'src/test_menu/declarer.dart';

///
/// The declarer class handling the logic
///
Declarer __declarer;

Declarer get _declarer {
  if (__declarer == null) {
    __declarer = Declarer();
    scheduleMicrotask(() {
      // An automatic microtask is run after the menu is declarer
      testMenuRun();
    });
  }
  return __declarer;
}

Declarer testMenuNewDeclarer() {
  __declarer = Declarer();
  return __declarer;
}

///
/// Declare a menu
///
/// declaration must be sync
///
void menu(String name, void Function() body,
    {String cmd, bool group, bool solo}) {
  _declarer.menu(name, body, cmd: cmd, group: group, solo: solo);
}

///
/// Declare a menu item
///
/// can return a future
///
/// @param cmd command shortcut (instead of incremental number)
void item(String name, dynamic Function() body,
    {String cmd, bool solo, bool test}) {
  _declarer.item(name, body, cmd: cmd, solo: solo, test: test);
}

///
/// Declare function called when we enter a menu
///
void enter(dynamic Function() body) {
  _declarer.enter(body);
}

///
/// Declare function called when we leave a menu
///
void leave(dynamic Function() body) {
  _declarer.leave(body);
}

// deprecated for temp usage only
@deprecated
// ignore: non_constant_identifier_names
void solo_item(String name, dynamic Function() body, {String cmd}) {
  item(name, body, cmd: cmd, solo: true);
}

// deprecated for temp usage only
@deprecated
// ignore: non_constant_identifier_names
void solo_menu(String name, void Function() body, {String cmd}) {
  menu(name, body, cmd: cmd, solo: true);
}

void write(Object message) {
  testMenuPresenter.write(message);
}

@deprecated
void devWrite(Object message) => write(message);

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
