/// Compat
library;

// ignore: implementation_imports
import 'package:dev_build/src/menu/dev_menu.dart';

export 'package:dev_build/src/menu/dev_menu.dart';

/// Test menu.
typedef TestMenu = DevMenu;

/// Test item.
typedef TestItem = DevMenuItem;

/// Runnable test item.
typedef RunnableTestItem = RunnableMenuItem;

/// Menu test item.
typedef MenuTestItem = MenuMenuItem;

/// Root test menu.
typedef RootTestMenu = RootMenu;
