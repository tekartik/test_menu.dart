library test_menu_console_interactive_test;

import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_mdl_browser.dart';

import 'common_test_menu.dart' as common_test_menu;

main() async {
  // ignore: deprecated_member_use
  TestMenuManager.debug.on = true;
  await initTestMenuBrowser();

  common_test_menu.main();
}
