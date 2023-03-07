import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

Future<void> platformMainMenu(
    List<String> arguments, void Function() declare) async {
  //if (isRunningAsJavascript) {}
  await initTestMenuBrowser();
  declare();
}
