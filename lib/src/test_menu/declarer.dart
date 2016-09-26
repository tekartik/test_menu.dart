//import 'test_menu.dart';

import '../../test_menu.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
//import '../common.dart';


/*
abstract class Callback {
  TestMenu parent;
  _Body body;
  var declareStackTrace;

  /// test group setUp or tearDown
  String get type {
    String type = runtimeType.toString();
    type = "${type[0].toLowerCase()}${type.substring(1)}";
    return type;
  }

  /// base implementation return the parent description
  List<String> get descriptions {
    if (parent != null) {
      return parent.descriptions;
    } else {
      return [];
    }
  }

  @override
  String toString() => '$type: $descriptions';

  @override
  int get hashCode => descriptions.length;

  // This is for testing mainly
  // 2 tests are the same if they have the same description
  @override
  bool operator ==(o) =>
      const ListEquality().equals(descriptions, o.descriptions);

  void declare();
}

*/

class Runner {
  Declarer declarer;

  Runner(this.declarer);

  Future run() async {
    TestMenu testMenu =declarer._testMenu;
    if (testMenu.length == 0) {
      write('No menu or item declared');
      // exiting
      return;
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
      showTestMenu(testMenu);
    }
  }

  void write(Object message) {
    testMenuManager.write(message);
  }
}

// current runner
Runner runner;

class Declarer {

  // current test menu
  TestMenu _testMenu = new TestMenu(null);

  void menu(String name, VoidFunc0 body, {String cmd}) {
    TestMenu newMenu = new TestMenu(name, cmd: cmd);
    _testMenu.addMenu(newMenu);

    TestMenu parentTestMenu = _testMenu;
    _testMenu = newMenu;
    body();
    _testMenu = parentTestMenu;
  }

  void item(String name, Func0 body, {String cmd, bool solo}) {
    TestItem item = new TestItem.fn(name, body, cmd: cmd, solo: solo);
    _testMenu.addItem(item);
    //_testMenu.add("print hi", () => print('hi'));
  }


  Future run() async {
    // simply show top menu, if empty exit, other go directly in sub menu
    //_testMenu.length

    runner = new Runner(this);
    await runner.run();





    //TODO wait for completion
    return new Future.value(runner);
  }
}
