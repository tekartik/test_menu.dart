/// Legacy entry points of the former Material Design Lite browser menu.
///
/// They now run the default web test menu (`test_menu_web.dart`), so old
/// code keeps working without the MDL scripts and styles.
@Deprecated('Use test_menu_web.dart')
library;

import 'test_menu_web.dart' as web;

export 'test_menu_web.dart' hide initTestMenuBrowser, mainMenu;

/// Element id of the former MDL menu list (not used by the web menu).
const String testMenuBrowserMenuId = 'test_menu';

/// Element id of the former MDL output (not used by the web menu).
const String testMenuBrowserOutputId = 'output';

/// Element id of the former MDL input (not used by the web menu).
const String testMenuBrowserInputId = 'input';

/// Init the web test menu, loading the [js] scripts first.
Future<void> initMenuBrowser({List<String>? js}) async {
  await initTestMenuBrowser(js: js);
}

/// Init the web test menu, loading the [js] scripts first.
Future<void> initTestMenuBrowser({List<String>? js}) async {
  await web.initTestMenuBrowser(jsFiles: js);
}

/// Main menu declaration.
Future<void> mainMenu(void Function() declare, {List<String>? js}) async {
  await mainMenuBrowser(declare, js: js);
}

/// Main menu declaration, loading the [js] scripts first.
Future<void> mainMenuBrowser(
  void Function() declare, {
  List<String>? js,
}) async {
  await initTestMenuBrowser(js: js);
  declare();
}
