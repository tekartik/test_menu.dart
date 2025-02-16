// ignore_for_file: deprecated_member_use_from_same_package

library;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

import 'browser_test_menu.dart' as browser_test_menu;
import 'common_test_menu.dart' as common_test_menu;

Future main() async {
  // ignore: deprecated_member_use
  TestMenuManager.debug.on = true;
  await initTestMenuBrowser();

  common_test_menu.commonTestMenu();
  browser_test_menu.browserTestMenu();
}
