/// Compat
library;

// ignore: implementation_imports
import 'package:dev_build/src/menu/menu_manager.dart';

export 'package:dev_build/src/menu/menu_manager.dart'
    show pushMenu, MenuManager;

typedef TestMenuManager = MenuManager;

bool get debugTestMenuManager => debugMenuManager;

TestMenuManager? get testMenuManager => menuManager;

void initTestMenuManager() {
  initMenuManager();
}
