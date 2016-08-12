library tekartik_test_menu_console;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'test_menu.dart';
import 'package:tekartik_core/dev_utils.dart';
import 'src/common.dart';

// set to false before checkin
bool testMenuConsoleDebug = false;

class _TestMenuManagerConsole extends TestMenuManager {

  static final String TAG = "[test_menu_console]";

  List<String> arguments;

  _TestMenuManagerConsole(this.arguments);

  // Not null if currently prompting
  Completer<String> promptCompleter;

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

  bool done = false;
  readLine() {
    if (_inCommand == null) {
      //devPrint('readLine');
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
    if (testMenuConsoleDebug) {
      print('$TAG Line: $line');
    }

    if (promptCompleter != null) {
      promptCompleter.complete(line);
      //Future done = promptCompleter.future;
      promptCompleter = null;
      //return done;
      return new Future.value();
    }
    TestMenu menu = displayedMenu;

    int value = int.parse(line, onError: (String textValue) {
      if (textValue == '-') {
        // print('pop');
        if (!pop()) {
          // devPrint('should exit?');
          done = true;
          if (_inCommandSubscription != null) {
            _inCommandSubscription.cancel();
          }
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
        if (testMenuConsoleDebug) {
          print("$TAG running '$value ${menu[value]}'");
        }
        return new Future.sync(menu[value].run).then((_) {
          if (testMenuConsoleDebug) {
            print("$TAG done '$value ${menu[value]}'");
          }
          //print('done');
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

  List<String> initialCommands;
  int initialCommandIndex = 0;
  Future _nextLine([_]) {
    if (initialCommands != null) {
      if (initialCommandIndex < initialCommands.length) {
        String commandLine = initialCommands[initialCommandIndex++];
        return processLine(commandLine).then(_nextLine);
      }
    }
    return new Future.value();
  }

  void _handleInput(TestMenu menu) {
    if (menu != displayedMenu) {
      _displayMenu(menu);
    }
    String name = menu.name != null ? "${menu.name} " : "";
    stdout.write('$name> ');

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
        initialCommands = lastArg.split(';');
      } on StateError catch (_) {}

      _nextLine();
      /*
      if ((commands != null) && (commands.length > 0)) {
        Future _processLine(int index) {
          if (index < commands.length) {
            return processLine(commands[index]).then((_) {
              return _processLine(index + 1);
            });
          }
          return new Future.value();
        }


      }
      */
    }
    // we might have exited with a - argument
    if (!done) {
      readLine();
    }

    //var input = stdin.
    //print(input.toUpperCase());
  }

  void showMenu(TestMenu menu) {
    _handleInput(menu);

    onProcessMenu(menu);
  }

  void write(Object message) {
    print("$message");
  }

  Future<String> prompt(Object message) {
    //print('$TAG Prompt: $message');
    message ??= "Enter text";
    stdout.write('$message > ');
    Completer completer = new Completer.sync();
    promptCompleter = completer;
    // read the next line
    _nextLine();
    return completer.future;
  }
}

void initTestMenuConsole(List<String> arguments) {
  _testMenuManagerConsole = new _TestMenuManagerConsole(arguments);
}

_TestMenuManagerConsole _testMenuManagerConsole;
