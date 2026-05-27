// ignore_for_file: depend_on_referenced_packages

library;

// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test.dart';

Future main() async {
  final subSubMenu = TestMenu('sub sub');
  subSubMenu.add('print hi', () => writeln('hi'));

  final subMenu = TestMenu('sub');
  subMenu.add('print hi', () => writeln('hi'));
  subMenu.addMenu(subSubMenu);

  final menu = TestMenu('main');
  menu.add('print hi', () => writeln('hi'));

  // late String text;
  menu.add('crash', () => throw StateError('crash'));
  menu.addMenu(subMenu);
  await pushMenu(menu);
}
