library test_menu_console_interactive_test;

import 'package:tekartik_test_menu/test_menu_mdl_browser.dart';
import 'package:tekartik_test_menu/test_menu.dart';

main() async {
  await initTestMenuBrowser();

  TestMenu subSubMenu = new TestMenu("sub sub");
  subSubMenu.add("print hi", () => print('hi'));

  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));
  subMenu.addMenu(subSubMenu);

  TestMenu menu = new TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);
}
