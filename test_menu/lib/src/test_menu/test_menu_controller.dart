// What to implement
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/test_menu.dart';

class TestMenuController {
  final void Function() declare;

  /// [declare your menu using item/menu
  TestMenuController(this.declare);

  TestMenu _testMenu;

  /// Resulting testMenu
  TestMenu get testMenu => _testMenu ??= () {
        var declarer = testMenuNewDeclarer();
        declare();
        return declarer.testMenu;
      }();
}
