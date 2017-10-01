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
    if (TestMenuManager.debug.on) {
      print('[Runner] menu $testMenu');
    }
    if (testMenu.length == 0 && testMenu.enters.length == 0) {
      write('No menu or item declared');
      // no longer exit, so that we handle the enter/leave
      //return;
    } else {
      /*
      if (testMenu.length == 1 && (testMenu[0] is MenuTestItem)) {
        if (TestMenuManager.debug.on) {
          print('[Runner] single main menu');
        }
        MenuTestItem item = testMenu[0] as MenuTestItem;
        testMenu = item.menu;
      }
      */
    }

    // look for solo stuff
    bool _hasSolo = false;

    List<TestMenu> tree = [];
    _handleSolo(TestMenu testMenu) async {
      tree.add(testMenu);
      for (TestItem item in testMenu.items) {
        if (item is RunnableTestItem) {
          if (item.solo == true) {
            _hasSolo = true;
            await testMenuManager.runItem(item);
            //await item.run();
          }
        } else if (item is MenuTestItem) {
          await _handleSolo(item.menu);
        }
      }
      tree.remove(testMenu);
    }

    await _handleSolo(testMenu);
    if (!_hasSolo) {
      await pushMenu(testMenu);
    }
  }

  void write(Object message) {
    testMenuPresenter?.write(message);
  }
}

// current runner
Runner runner;
