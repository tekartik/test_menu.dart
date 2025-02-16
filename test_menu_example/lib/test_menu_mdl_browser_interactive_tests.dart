// ignore_for_file: deprecated_member_use

library;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

import 'common_test_menu.dart' as common_test_menu;

Future main() async {
  TestMenuManager.debug.on = true;
  await initTestMenuBrowser();

  common_test_menu.main();
}
