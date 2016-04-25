library tekartik_test_menu_console;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'test_menu.dart';

class _TestMenuManagerConsole extends TestMenuManager {
  List<String> arguments;

  _TestMenuManagerConsole(this.arguments);

  TestMenu displayedMenu = null;
  bool _argumentsHandled = false;
  void _displayMenu(TestMenu menu) {
    displayedMenu = menu;
    //print('- exit');
    for (int i = 0; i < menu.length; i++) {
      TestItem item = menu[i];
      print('$i ${item}');
    }
  }
/*
  void _handleInputOld(TestMenu menu) {
    while (true) {
      if (menu != displayedMenu) {
        _displayMenu(menu);
      }
      stdout.write('> ');
      var input = stdin.readLineSync();
      //print(input.toUpperCase());

      int value = int.parse(input, onError: (String textValue) {
        if (textValue == '-') {
          return -1;
        }
        if (textValue == '.') {
          _displayMenu(menu);
          return null;
        }
        print('errorValue: $textValue');
        print('- exit');
        print('. display menu again');
      });
      if (value != null) {
        if (value >= 0 && value < menu.length) {
          print("running '$value ${menu[value]}'");
          //var runResult = menu[value].run();
//          if (runResult is Future) {
//
//          }
        }
        if (value == -1) {
          break;
        }
        ;
      }
    }
    print('finished');
  }
  */

  Stream _inCommand;
  StreamSubscription _inCommandSubscription;

  readLine() {
    if (_inCommand == null) {
      _inCommand = stdin.transform(UTF8.decoder).transform(new LineSplitter());

      _inCommandSubscription = _inCommand.listen(handleLine);
    }

    //return _inCommand.
  }

  Future handleLine(String line) {
    return processLine(line).then((_) {
      stdout.write('> ');
    });
  }

  Future processLine(String line) {
    TestMenu menu = displayedMenu;
    // print('Line: $line');

    int value = int.parse(line, onError: (String textValue) {
      if (textValue == '-') {
        print('pop');
        if (!pop()) {
          _inCommandSubscription.cancel();
        }
        return -1;
      }
      if (textValue == '.') {
        _displayMenu(menu);
        return null;
      }
      print('errorValue: $textValue');
      print('- exit');
      print('. display menu again');
    });
    if (value != null) {
      if (value >= 0 && value < menu.length) {
        print("running '$value ${menu[value]}'");
        return new Future.sync(menu[value].run).then((_) {
          print('done');
        });
        // }
//        if (value == -1) {
//          break;
//        };
      }
    }
    return new Future.value();
  }

  //void main() {
  //readLine().listen(processLine);
  //}

  void _handleInput(TestMenu menu) {
    if (menu != displayedMenu) {
      _displayMenu(menu);
    }
    stdout.write('> ');

//      Completer<String> completer = new Completer();
//      //stdin.readByteSync();
//      completer.future.then((String command) {
//        print('FUTURE: $command');
//      });
    if (!_argumentsHandled) {
      _argumentsHandled = true;
      List<String> commands;
      try {
        String lastArg = arguments.last;
        commands = lastArg.split(';');
      } on StateError catch (_) {}

      if ((commands != null) && (commands.length > 0)) {
        Future _processLine(int index) {
          if (index < commands.length) {
            return processLine(commands[index]).then((_) {
              return _processLine(index + 1);
            });
          }
          return new Future.value();
        }

        _processLine(0);
      }
    }
    readLine();

    //var input = stdin.
    //print(input.toUpperCase());
  }

  void showMenu(TestMenu menu) {
    _handleInput(menu);

    onProcessMenu(menu);
  }
}

void initTestMenuConsole(List<String> arguments) {
  _testMenuManagerConsole = new _TestMenuManagerConsole(arguments);
}

_TestMenuManagerConsole _testMenuManagerConsole;
