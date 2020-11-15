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
  TestMenu testMenu = RootTestMenu();

  void menu(String name, void Function() body,
      {String cmd, bool group, bool solo}) {
    final parentTestMenu = testMenu;

    final newMenu = TestMenu(name, cmd: cmd, group: group, solo: solo);
    parentTestMenu.addMenu(newMenu);

    testMenu = newMenu;
    body();
    testMenu = parentTestMenu;
  }

  void command(dynamic Function(String command) body) {
    final command = MenuCommand(body);
    testMenu.setCommand(command);
  }

  void enter(Function() body) {
    final enter = MenuEnter(body);
    testMenu.addEnter(enter);
  }

  void leave(Function() body) {
    final leave = MenuLeave(body);
    testMenu.addLeave(leave);
  }

  void item(String name, Function() body, {String cmd, bool solo, bool test}) {
    final item = TestItem.fn(name, body, cmd: cmd, solo: solo, test: test);
    testMenu.addItem(item);
    //_testMenu.add("print hi", () => print('hi'));
  }

  Future run() async {
    // simply show top menu, if empty exit, other go directly in sub menu
    //_testMenu.length

    runner = Runner(this);
    await runner.run();

    //TODO wait for completion
    return Future.value(runner);
  }
}
