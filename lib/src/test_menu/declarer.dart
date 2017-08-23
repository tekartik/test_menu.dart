//import 'test_menu.dart';

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu/src/test_menu/runner.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
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

// Not public
class Declarer {
  // current test menu
  TestMenu testMenu = new TestMenu(null);

  void menu(String name, VoidFunc0 body, {String cmd}) {
    TestMenu newMenu = new TestMenu(name, cmd: cmd);
    testMenu.addMenu(newMenu);

    TestMenu parentTestMenu = testMenu;
    testMenu = newMenu;
    body();
    testMenu = parentTestMenu;
  }

  void enter(Func0 body) {
    MenuEnter enter = new MenuEnter(body);
    testMenu.addEnter(enter);
  }

  void leave(Func0 body) {
    MenuLeave leave = new MenuLeave(body);
    testMenu.addLeave(leave);
  }

  void item(String name, Func0 body, {String cmd, bool solo}) {
    TestItem item = new TestItem.fn(name, body, cmd: cmd, solo: solo);
    testMenu.addItem(item);
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
