library test_menu_console_interactive_test;

// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

Future main() async {
  TestMenu subSubMenu = TestMenu("sub sub");
  subSubMenu.add("print hi", () => print('hi'));

  TestMenu subMenu = TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));
  subMenu.addMenu(subSubMenu);

  TestMenu menu = TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.add("crash", () => print(null.length));
  menu.addMenu(subMenu);
  await pushMenu(menu);
}
