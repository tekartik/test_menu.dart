part of tekartik_test_menu;

abstract class TestMenuManager {
  TestMenu displayedMenu;

  TestMenu get activeMenu {
    if (stackMenus.length > 0) {
      return stackMenus.last;
    }
    return null;
  }

  List<TestMenu> stackMenus = new List();

  static List<String> initCommandsFromHash(String hash) {
    print("hash: $hash");
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
    print("hash: $hash commands: $commands");
    return commands;
  }

  TestMenuManager() {
    testMenuManager = this;
  }
  TestMenu _startMenu;

  void setStartMenu(TestMenu menu) {
    _startMenu = menu;
  }

  void push(TestMenu menu) {
    if (stackMenus.contains(menu)) {
      return;
    }
    stackMenus.add(menu);
    showMenu(menu);
  }

  bool pop([int count = 1]) {
    if (stackMenus.length > 1) {
      stackMenus.removeRange(stackMenus.length - count, stackMenus.length);
      showMenu(activeMenu);
      return true;
    }
    return false;
  }

  int get activeDepth {
    return stackMenus.length - 1;
  }

  void showMenu(TestMenu menu);
  void write(Object message);
  Future<String> prompt(Object message);

  Future runItem(TestItem item) {
    print("running '$item'");
    onProcessItem(item);
    return new Future.sync(item.run).then((_) {
      print("done '$item'");
    });
  }

  /**
   * Commands executed on startup
   */
  List<String> initCommands;

  void stop() {
    // _inCommandSubscription.cancel();
  }

  Future processLine(String line) {
    TestMenu menu = displayedMenu;
    // print('Line: $line');

    int value = int.parse(line, onError: (String textValue) {
      if (textValue == '-') {
        print('pop');
        if (!pop()) {
          stop();
        }
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
    if (value != null) {
      if (value >= 0 && value < menu.length) {
        return runItem(menu[value]);
        // }
        //        if (value == -1) {
        //          break;
        //        };
      }
    }
    return new Future.value();
  }

  bool _initCommandHandled = false;
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

  void onProcessItem(TestItem item) {}
}

TestMenuManager testMenuManager;
