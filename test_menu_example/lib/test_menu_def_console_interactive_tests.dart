library;

import 'package:tekartik_test_menu_io/test_menu_io.dart';

import 'src/common_test_menu_def.dart' as common_test_menu;

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
