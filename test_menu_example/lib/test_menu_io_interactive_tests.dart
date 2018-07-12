library test_menu_console_interactive_test;

//import 'package:tekartik_test_menu/src/common_import.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

import 'common_test_menu.dart' as common_test_menu;

void main(List<String> arguments) {
  //TestMenuManager.debug.on = true;

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
