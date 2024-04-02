library tekartik_test_menu;

import 'package:tekartik_test_menu/test_menu.dart';

export 'package:dev_build/menu/menu.dart';
export 'src/test_menu/test_menu_manager.dart' show TestMenuManager;

/// Run a menu.
Future<void> testMenuRun() async {
  await menuRun();
}
