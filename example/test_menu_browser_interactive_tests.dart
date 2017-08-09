library test_menu_console_interactive_test;

import 'package:tekartik_test_menu/test_menu_browser.dart';
import 'package:tekartik_test_menu/test_menu.dart';
import 'common_test_menu.dart' as common_test_menu;

void main() {
  initTestMenuBrowser();

  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));

  TestMenu menu = new TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);

  common_test_menu.main();
}
