/// Declare a manual menu: `menu`, `item`, `enter`, `leave`, `enterItem`,
/// `leaveItem`, `command`, `write`, `writeln`, `prompt`, `showMenu`,
/// `popMenu` (from `package:dev_build/menu/menu.dart`) and [testMenuRun].
///
/// Platform agnostic, a runner package (io, browser, node, Flutter) shows
/// the menu.
library;

import 'package:tekartik_test_menu/test_menu.dart';

export 'package:dev_build/menu/menu.dart';
export 'src/test_menu/test_menu_manager.dart' show TestMenuManager;

/// Run a menu.
Future<void> testMenuRun() async {
  await menuRun();
}
