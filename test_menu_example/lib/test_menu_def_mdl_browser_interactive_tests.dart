library;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

import 'src/common_test_menu_def.dart' as common_test_menu;

Future main() async {
  await initTestMenuBrowser();

  await common_test_menu.main();
}
