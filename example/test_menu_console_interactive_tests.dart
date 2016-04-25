library test_menu_console_interactive_test;

import 'package:tekartik_test_menu/test_menu_console.dart';
import 'package:tekartik_test_menu/test_menu.dart';

void main(List<String> arguments) {
  initTestMenuConsole(arguments);

  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));

  TestMenu menu = new TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);
}
