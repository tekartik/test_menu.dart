import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:stack_trace/stack_trace.dart';

//import 'src/common.dart';
bool get debugTestMenuManager => TestMenuManager.debug.on;

initTestMenuManager() {
  if (testMenuManager == null) {
    if (testMenuPresenter != null) {
      testMenuManager = new TestMenuManagerDefault(testMenuPresenter);
    } else {
      throw ('Cannot tell whether you\'re running from io or browser. Please include the proper header');
    }
  }
}

@deprecated
void showTestMenu(TestMenu menu) {
  initTestMenuManager();
  testMenuManager.push(menu);
}

Future pushMenu(TestMenu menu) async {
  initTestMenuManager();
  return await testMenuManager.pushMenu(menu);
}

Future popMenu() async {
  return await testMenuManager.popMenu();
}

Future processMenu(TestMenu menu) async {
  return await testMenuManager.processMenu(menu);
}

class TestMenuManagerDefault extends TestMenuManager {
  TestMenuPresenter presenter;

  TestMenuManagerDefault(this.presenter);

  @override
  Future presentMenu(TestMenu menu) async {
    await testMenuPresenter.presentMenu(menu);
  }

  @override
  Future<String> prompt(Object message) {
    return testMenuPresenter.prompt(message);
  }

  @override
  void write(Object message) {
    return testMenuPresenter.write(message);
  }

  Future runItem(TestItem item) async {
    await testMenuPresenter.preProcessItem(item);
    await super.runItem(item);
  }
}

abstract class TestMenuManager {
  static final DevFlag debug = new DevFlag("TestMenuManager");
  //TestMenu displayedMenu;

  TestMenu get activeMenu {
    if (stackMenus.length > 0) {
      return stackMenus.last;
    }
    return null;
  }

  List<TestMenu> stackMenus = new List();

  static List<String> initCommandsFromHash(String hash) {
    if (debugTestMenuManager) {
      print("hash: $hash");
    }
    int firstHash = hash.indexOf('#');
    if (firstHash == 0) {
      int nextHash = hash.indexOf('#', 1);
      if (nextHash < 0) {
        hash = hash.substring(1);
      } else {
        hash = hash.substring(firstHash + 1, nextHash);
      }
    } else if (firstHash > 0) {
      hash = hash.substring(0, firstHash);
    }
    List<String> commands = hash.split('_');
    if (debugTestMenuManager) {
      print("hash: $hash commands: $commands");
    }
    return commands;
  }

  TestMenuManager() {
    // unique?
    testMenuManager = this;
  }

  /*
  TestMenu _startMenu;

  void setStartMenu(TestMenu menu) {
    _startMenu = menu;
  }
  */

  Future pushMenu(TestMenu menu) async {
    if (_push(menu)) {
      await presentMenu(menu);
      await runEnters(menu);
    }
    return true;
  }

  @deprecated
  bool push(TestMenu menu) {
    if (_push(menu)) {
      presentMenu(menu);
    }
    return true;
  }

  bool _push(TestMenu menu) {
    if (stackMenus.contains(menu)) {
      return false;
    }
    stackMenus.add(menu);
    return true;
  }

  Future<bool> popMenu([int count = 1]) async {
    TestMenu activeMenu = this.activeMenu;
    bool poped = _pop(count);
    if (poped && activeMenu != null) {
      await runLeaves(activeMenu);
      await presentMenu(this.activeMenu);
    }
    return poped;
  }

  /*
  @deprecated
  bool pop([int count = 1]) {
    if (_pop(count)) {
      presentMenu(activeMenu);
      return true;
    }
    return false;
  }
  */

  bool _pop([int count = 1]) {
    if (stackMenus.length > 1) {
      stackMenus.removeRange(stackMenus.length - count, stackMenus.length);
      return true;
    }
    return false;
  }

  int get activeDepth {
    return stackMenus.length - 1;
  }

  // to override
  Future presentMenu(TestMenu menu);

  void write(Object message);

  Future<String> prompt(Object message);

  Future run(Runnable runnable) async {
    if (debugTestMenuManager) {
      print("[run] running '$runnable'");
    }
    try {
      await runnable.run();
    } catch (e, st) {
      write("ERROR CAUGHT $e ${Trace.format(st)}");
      rethrow;
    } finally {
      if (debugTestMenuManager) {
        print("[run] done '$runnable'");
      }
    }
  }

  Future runEnters(TestMenu menu) async {
    for (var enter in menu.enters) {
      await run(enter);
    }
  }

  Future runLeaves(TestMenu menu) async {
    for (var leave in menu.leaves) {
      await run(leave);
    }
  }

  Future runItem(TestItem item) async {
    if (debugTestMenuManager) {
      print("[runItem] running '$item'");
    }
    //onProcessItem(item);
    try {
      await item.run();
    } catch (e, st) {
      write("ERROR CAUGHT $e ${Trace.format(st)}");
      rethrow;
    } finally {
      if (debugTestMenuManager) {
        print("[runItem] '$item'");
      }
    }
  }

  /**
   * Commands executed on startup
   */
  List<String> initCommands;

  void stop() {
    // _inCommandSubscription.cancel();
  }

  // Process a command line
  Future processLine(String line) async {
    TestMenu menu = activeMenu;
    //devPrint('Line: $line / Menu $menu');

    int value = int.parse(line, onError: (String textValue) {
      if (textValue == '-') {
        print('pop');

        return -1;
      }
      //         if (textValue == '.') {
      //           _displayMenu(menu);
      //           return null;
      //         }
      //         print('errorValue: $textValue');
      //         print('- exit');
      //         print('. display menu again');
    });
    if (value == -1) {
      if (!await popMenu()) {
        stop();
      }
    } else {
      if (value != null) {
        if (value >= 0 && value < menu.length) {
          return runItem(menu[value]);
          // }
          //        if (value == -1) {
          //          break;
          //        };
        }
      }
    }
  }

  bool _initCommandHandled = false;

  // Process current menu
  // Run initial commands if needed first
  Future processMenu(TestMenu menu) async {
    if (!_initCommandHandled) {
      _initCommandHandled = true;

      List<String> initCommands = this.initCommands;
      if (initCommands != null) {
        for (String initCommand in initCommands) {
          await processLine(initCommand);
        }
      }
    }
  }

  /*
  @deprecated
  void onProcessMenu(TestMenu menu) {
    if (!_initCommandHandled) {
      _initCommandHandled = true;

      List<String> initCommands = this.initCommands;
      Future _processLine(int index) {
        if (initCommands != null && index < initCommands.length) {
          return processLine(initCommands[index]).then((_) {
            return _processLine(index + 1);
          });
        }
        return new Future.value();
      }

      _processLine(0);
    }
  }
  */

  //void onProcessItem(TestItem item) {}
}

TestMenuManager testMenuManager;
