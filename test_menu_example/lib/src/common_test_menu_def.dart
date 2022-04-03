// ignore_for_file: depend_on_referenced_packages

library test_menu_console_interactive_test;

// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

Future main() async {
  final subSubMenu = TestMenu('sub sub');
  subSubMenu.add('print hi', () => print('hi'));

  final subMenu = TestMenu('sub');
  subMenu.add('print hi', () => print('hi'));
  subMenu.addMenu(subSubMenu);

  final menu = TestMenu('main');
  menu.add('print hi', () => print('hi'));

  // late String text;
  menu.add('crash', () => throw 'crash');
  menu.addMenu(subMenu);
  await pushMenu(menu);
}
