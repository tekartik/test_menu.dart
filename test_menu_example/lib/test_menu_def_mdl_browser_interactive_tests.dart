library test_menu_console_interactive_test;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

import 'src/common_test_menu_def.dart' as common_test_menu;

main() async {
  await initTestMenuBrowser();

  common_test_menu.main();
}
