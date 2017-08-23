import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu/src/test_menu/declarer.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

class Runner {
  Declarer declarer;

  Runner(this.declarer);

  Future run() async {
    TestMenu testMenu = declarer.testMenu;
    if (testMenu.length == 0 && testMenu.enters.length == 0) {
      write('No menu or item declared');
      // no longer exit, so that we handle the enter/leave
      //return;
    } else {
      if (testMenu.length == 1 && (testMenu[0] is MenuTestItem)) {
        MenuTestItem item = testMenu[0] as MenuTestItem;
        testMenu = item.menu;
      }
    }

    // look for solo stuff
    bool _hasSolo = false;

    _handleSolo(TestMenu testMenu) async {
      for (TestItem item in testMenu.items) {
        if (item is RunnableTestItem) {
          if (item.solo == true) {
            _hasSolo = true;
            await item.run();
          }
        } else if (item is MenuTestItem) {
          _handleSolo(item.menu);
        }
      }
    }

    await _handleSolo(testMenu);
    if (!_hasSolo) {
      await pushMenu(testMenu);
    }
  }

  void write(Object message) {
    if (testMenuPresenter != null) {
      testMenuPresenter.write(message);
    } else {
      //compatibility
      testMenuManager.write(message);
    }
  }
}

// current runner
Runner runner;
