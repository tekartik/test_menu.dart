library;

import 'package:dev_build/menu/menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

void main() {
  final subSubMenu = TestMenu('sub sub');
  subSubMenu.add('print hi', () => writeln('hi'));

  final subMenu = TestMenu('sub');
  subMenu.add('print hi', () => writeln('hi'));
  subMenu.addMenu(subSubMenu);

  final menu = TestMenu('main');
  menu.add('print hi', () => writeln('hi'));
  menu.add('crash', () => throw StateError('crash'));
  menu.addMenu(subMenu);
  pushMenu(menu);
}
