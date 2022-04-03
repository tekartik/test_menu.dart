import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu/src/test_menu/declarer.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

class Runner {
  Declarer declarer;

  Runner(this.declarer);

  Future run() async {
    final testMenu = declarer.testMenu;
    if (TestMenuManager.debug.on) {
      print('[Runner] menu $testMenu');
    }
    if (testMenu.length == 0 && testMenu.enters.isEmpty) {
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

    //List<List<TestItem> >
    final tree = <TestMenu>[];
    List<TestMenu>? soloTree;
    RunnableTestItem? soloTestItem;
    Future _handleSolo(TestMenu testMenu) async {
      tree.add(testMenu);

      // handle solo_menu
      if (testMenu.solo == true) {
        soloTree = List.from(tree);
      }

      for (final item in testMenu.items) {
        if (item is RunnableTestItem) {
          // handle solo_item
          if (item.solo == true) {
            soloTestItem = item;
            soloTree = List.from(tree);
            //        await testMenuManager.runItem(item);

            //await item.run();
          }
        } else if (item is MenuTestItem) {
          await _handleSolo(item.menu);
        }
      }
      tree.remove(testMenu);
    }

    // look for solo stuff
    await _handleSolo(testMenu);

    final hasSolo = soloTree != null;
    if (!hasSolo) {
      await pushMenu(testMenu);
    } else {
      for (var testMenu in soloTree!) {
        await pushMenu(testMenu);
      }
      try {
        if (soloTestItem != null) {
          await testMenuManager!.runItem(soloTestItem!);
        }
      } catch (e, st) {
        print(e);
        print(st);
      }
    }
  }

  void write(Object message) {
    testMenuPresenter.write(message);
  }
}

// current runner
Runner? runner;
