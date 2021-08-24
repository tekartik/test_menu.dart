import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_runner.dart';
import 'package:tekartik_test_menu/test_menu.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

bool get debugTestMenuManager => TestMenuManager.debug.on;

// There is only one test menu manager
TestMenuManager? _testMenuManager;

TestMenuManager? get testMenuManager {
  _testMenuManager ??= TestMenuManager(testMenuPresenter);

  return _testMenuManager;
}

set testMenuManager(TestMenuManager? testMenuManager) =>
    _testMenuManager = testMenuManager;

void initTestMenuManager() {}

Future pushMenu(TestMenu menu) async {
  initTestMenuManager();
  return await testMenuManager!.pushMenu(menu);
}

Future<bool> popMenu() async {
  return await testMenuManager!.popMenu();
}

Future processMenu(TestMenu menu) async {
  return await testMenuManager!.processMenu(menu);
}

class TestMenuManager {
  final TestMenuPresenter presenter;
  var lock = Lock(reentrant: true);
  static final DevFlag debug = DevFlag('TestMenuManager');

  //TestMenu displayedMenu;
  Map<TestMenu, TestMenuRunner> menuRunners = {};

  TestMenuRunner? get activeMenuRunner {
    if (stackMenus.isNotEmpty) {
      return stackMenus.last;
    }
    return null;
  }

  TestMenu? get activeMenu => activeMenuRunner?.menu;

  List<TestMenuRunner> get stackMenus => _stackMenus;
  final _stackMenus = <TestMenuRunner>[];

  static List<String> initCommandsFromHash(String hash) {
    if (debugTestMenuManager) {
      print('hash: $hash');
    }
    final firstHash = hash.indexOf('#');
    if (firstHash == 0) {
      final nextHash = hash.indexOf('#', 1);
      if (nextHash < 0) {
        hash = hash.substring(1);
      } else {
        hash = hash.substring(firstHash + 1, nextHash);
      }
    } else if (firstHash > 0) {
      hash = hash.substring(0, firstHash);
    }
    final commands = hash.split('_');

    if (debugTestMenuManager) {
      print('hash: $hash commands: $commands');
    }
    return commands;
  }

  TestMenuManager(this.presenter) {
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
      if (TestMenuManager.debug.on) {
        write('[mgr] push presenting $menu');
      }
      presenter.presentMenu(menu);

      //eventually process init items
      await menuRunners[menu]?.enter();

      await processMenu(menu);
    }
    return true;
  }

  /// Return when closed!
  Future showMenu(TestMenu menu) async {
    await pushMenu(menu);
    await menuRunners[menu]!.done;
  }

  bool stackContainsMenu(TestMenu menu) {
    return menuRunners[menu] != null;
  }

  bool _push(TestMenu menu) {
    if (stackContainsMenu(menu)) {
      return false;
    }
    if (menu.parent != null) {
      if (!stackContainsMenu(menu.parent!)) {
        if (!_push(menu.parent!)) {
          print('cant push ${menu.parent}');
          return false;
        }
      }
    }
    if (TestMenuManager.debug.on) {
      write('[mgr] pushMenu $menu to ${testMenuManager!.stackMenus}');
    }
    // Make sure parent runner exists
    final runner = TestMenuRunner(activeMenuRunner, menu);
    return _pushMenuRunner(runner);
  }

  bool _pushMenuRunner(TestMenuRunner menuRunner) {
    //if (stackMenus.contains(menuRunner)) {
    //  return false;
    //}
    menuRunners[menuRunner.menu] = menuRunner;
    stackMenus.add(menuRunner);
    return true;
  }

  bool canPop([int count = 1]) {
    return activeDepth >= count;
  }

  Future<bool> popMenu([int count = 1]) async {
    final activeMenuRunner = this.activeMenuRunner;
    if (TestMenuManager.debug.on) {
      write(
          '[mgr] poping $activeMenuRunner from ${testMenuManager!.stackMenus}');
    }
    final poped = _pop(count);
    if (poped && activeMenuRunner != null) {
      await activeMenuRunner.leave();
      if (TestMenuManager.debug.on) {
        write('[mgr] pop presenting ${this.activeMenuRunner!.menu}');
      }
      presenter.presentMenu(this.activeMenuRunner!.menu);
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
    if (TestMenuManager.debug.on) {
      write('$stackMenus poping $count');
    }

    if (stackMenus.length > count) {
      if (TestMenuManager.debug.on) {
        write('$stackMenus after poping $count');
      }
      // Remove and clear menuRunners
      final start = stackMenus.length - count;
      final end = stackMenus.length;
      final removedRunner = stackMenus.sublist(start, end);
      for (final menuRunner in removedRunner) {
        menuRunners.remove(menuRunner.menu);
      }
      stackMenus.removeRange(start, end);

      if (TestMenuManager.debug.on) {
        write('$stackMenus after poping $count');
      }
      return true;
    }
    return false;
  }

  int get activeDepth {
    return stackMenus.length - 1;
  }

  // Get or create the runner for a given item
  TestMenuRunner getRunner(WithParent item) {
    if (item.parent is! RootTestMenu) {
      getRunner(item.parent!);
    }
    var runner = menuRunners[item.parent];
    if (runner == null) {
      //devPrint('getRunner $item');

      _push(item.parent!);
      runner = menuRunners[item.parent];
    }
    return runner!;
  }

  // make sure the menu is entered first
  Future runItem(TestItem item) async {
    // await _enterMenu(item.parent);
    final runner = getRunner(item);
    //await runner.enter();
    if (item is MenuTestItem) {
      await pushMenu(item.menu);
    } else {
      // Update hash in browser for example
      await testMenuPresenter.preProcessItem(item);
      await runner.run(item);
    }
  }

  /// Commands executed on startup
  List<String>? initCommands;

  void stop() {
    // _inCommandSubscription.cancel();
  }

  // Process a command line
  Future processLine(String line) async {
    final menu = activeMenu;
    //devPrint('Line: $line / Menu $menu');

    var value = int.tryParse(line);
    if (value == null) {
      if (line == '-') {
        print('pop');

        value = -1;
      }
      //         if (textValue == '.') {
      //           _displayMenu(menu);
      //           return null;
      //         }
      //         print('errorValue: $textValue');
      //         print('- exit');
      //         print('. display menu again');
    }
    if (value == -1) {
      if (!await popMenu()) {
        stop();
      }
    } else {
      if (value != null) {
        if (value >= 0 && value < menu!.length) {
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

      final initCommands = this.initCommands;
      if (initCommands != null) {
        for (final initCommand in initCommands) {
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
