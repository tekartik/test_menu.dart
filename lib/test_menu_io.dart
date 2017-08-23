library tekartik_test_menu_console;

import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

import 'src/common_io.dart';

export 'src/common_io.dart';
export 'test_menu.dart';

// set to false before checkin
bool testMenuConsoleDebug = false;

String _exitCommand = ".";
String _helpCommand = "h";

class _TestMenuManagerConsole extends TestMenuPresenter
    with TestMenuPresenterMixin {
  static final String TAG = "[test_menu_console]";

  List<String> arguments;

  bool verbose;

  _TestMenuManagerConsole(this.arguments) {
    var parser = new ArgParser();
    parser.addFlag('help', abbr: 'h');
    parser.addFlag('verbose', abbr: 'v');

    var results = parser.parse(arguments);
    verbose = results['verbose'] || testMenuConsoleDebug;
    if (verbose) {
      stdout.writeln("args: $arguments");
    }
    if (results['help']) {
      stdout.writeln("Add arguments at the end separated by spaces");
      stdout.writeln("Example to run item 0 and exit");
      stdout.writeln("  dart test_menu.dart 0 -");
      exit(0);
    }

    initialCommands = results.rest;
  }

  // Not null if currently prompting
  Completer<String> promptCompleter;

  TestMenu displayedMenu = null;
  bool _argumentsHandled = false;

  void _displayMenu(TestMenu menu) {
    displayedMenu = menu;
    //print('- exit');
    for (int i = 0; i < menu.length; i++) {
      TestItem item = menu[i];
      String cmd = item.cmd ?? '$i';
      print('$cmd ${item}');
    }
  }

  Stream _inCommand;
  StreamSubscription _inCommandSubscription;

  bool done = false;

  readLine() {
    if (_inCommand == null) {
      //devPrint('readLine');
      _inCommand = stdin.transform(UTF8.decoder).transform(new LineSplitter());

      // Waiting forever on stdin
      _inCommandSubscription = _inCommand.listen(handleLine);
    }

    //return _inCommand.
  }

  Future handleLine(String line) {
    return processLine(line).then((_) {
      stdout.write('> ');
    });
  }

  Future processLine(String line) async {
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

    // Exit
    if (line == _exitCommand) {
      // print('pop');
      if (!await popMenu()) {
        // devPrint('should exit?');
        done = true;
        if (_inCommandSubscription != null) {
          _inCommandSubscription.cancel();
        }
      }
      return new Future.value();
    }

    // Help
    if (line == _helpCommand) {
      _displayMenu(menu);
      return new Future.value();
    }

    TestItem item = menu.byCmd(line);
    if (item != null) {
      if (verbose) {
        print("$TAG running '$item'");
      }

      return new Future.sync(item.run).then((_) {
        if (verbose) {
          print("$TAG done '$item'");
        }
      });
    } else {
      print('errorValue: $line');
      print('$_exitCommand exit');
      print('$_helpCommand display menu again');
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

  @override
  void presentMenu(TestMenu menu) {
    _handleInput(menu);

    processMenu(menu);
  }

  void write(Object message) {
    stdout.writeln("$message");
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
  // set current
  testMenuPresenter = _testMenuManagerConsole;
}

_TestMenuManagerConsole _testMenuManagerConsole;

void mainMenu(List<String> arguments, VoidFunc0 body) {
  initTestMenuConsole(arguments);
  body();
}
