import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

import 'common_test_menu.dart' as common_test_menu;
import 'universal_test_menu.dart' as universal_test_menu;

Future<void> main(List<String> arguments) async {
  await mainMenu(arguments, () {
    common_test_menu.commonTestMenu();
    universal_test_menu.universalTestMenu();
  });
}
