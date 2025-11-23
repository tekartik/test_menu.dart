/// Compat
library;

// ignore: implementation_imports
import 'package:dev_build/src/menu/menu_manager.dart';

export 'package:dev_build/src/menu/menu_manager.dart'
    show pushMenu, MenuManager;

/// Test menu manager.
typedef TestMenuManager = MenuManager;

/// Debug flag.
bool get debugTestMenuManager => debugMenuManager;

/// Global menu manager.
TestMenuManager? get testMenuManager => menuManager;

/// Init the menu manager.
void initTestMenuManager() {
  initMenuManager();
}
