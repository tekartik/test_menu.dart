// ignore: implementation_imports
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
// ignore: implementation_imports
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

/// The location hash parts of the menu stack: the index of each menu in its
/// parent menu, then the index of [item] in the active menu if any.
List<String> testMenuStackNames([TestItem? item]) {
  final manager = testMenuManager!;
  final stackMenus = manager.stackMenus;
  final list = <String>[];

  TestMenu? lastMenu;
  for (var i = stackMenus.length - 1; i >= 0; i--) {
    final menu = stackMenus[i].menu;

    int index;

    if (lastMenu == null) {
      lastMenu = manager.activeMenu;
      if (item == null) {
        continue;
      }
      index = manager.activeMenu!.indexOfItem(item);
    } else {
      index = menu.indexOfMenu(lastMenu);
      lastMenu = menu;
    }

    list.insert(0, index.toString());
  }
  return list;
}
