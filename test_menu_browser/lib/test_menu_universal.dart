import 'package:tekartik_test_menu_browser/src/platform/platform.dart';
export 'package:tekartik_test_menu/test_menu.dart';

/// Main menu declaration
Future<void> mainMenu(List<String> arguments, void Function() declare) async {
  await platformMainMenu(arguments, declare);
}
