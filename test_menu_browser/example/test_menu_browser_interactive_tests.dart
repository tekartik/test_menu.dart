// ignore_for_file: deprecated_member_use_from_same_package

library;

import 'package:tekartik_test_menu_browser/test_menu_browser.dart';

import 'common_test_menu.dart' as common_test_menu;

void main() {
  initTestMenuBrowser();

  /*
  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));

  TestMenu menu = new TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);
  */

  common_test_menu.commonTestMenu();
}
