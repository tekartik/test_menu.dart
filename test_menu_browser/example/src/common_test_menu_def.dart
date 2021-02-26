library test_menu_console_interactive_test;

import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

void main() {
  final subSubMenu = TestMenu('sub sub');
  subSubMenu.add('print hi', () => print('hi'));

  final subMenu = TestMenu('sub');
  subMenu.add('print hi', () => print('hi'));
  subMenu.addMenu(subSubMenu);

  final menu = TestMenu('main');
  menu.add('print hi', () => print('hi'));
  menu.add('crash', () => throw 'crash');
  menu.addMenu(subMenu);
  pushMenu(menu);
}
