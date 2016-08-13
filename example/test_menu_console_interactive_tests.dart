library test_menu_console_interactive_test;

import 'package:tekartik_test_menu/test_menu_console.dart';

import 'common_test_menu.dart' as common_test_menu;

void main(List<String> arguments) {
  initTestMenuConsole(arguments);

  common_test_menu.main();
  /*

  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));

  TestMenu menu = new TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);
  */
}
