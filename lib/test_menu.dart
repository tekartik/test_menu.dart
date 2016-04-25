library tekartik_test_menu;

import 'dart:async';

part 'src/test_menu/test_menu.dart';
part 'src/test_menu/test_menu_manager.dart';

void showTestMenu(TestMenu menu) {
  testMenuManager.push(menu);
}
