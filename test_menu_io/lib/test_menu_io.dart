library tekartik_test_menu_console;

import 'dart:io' hide stdin;

import 'package:process_run/shell.dart';
import 'package:args/args.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

import 'src/common_io.dart';

export 'package:tekartik_test_menu/test_menu.dart';

export 'src/common_io.dart';
// ignore_for_file: implementation_imports

// set to false before checkin
bool testMenuConsoleDebug = false; //devWarning(true); // false;

String _exitCommand = '.';
String _helpCommand = '?';

class _TestMenuManagerConsole extends TestMenuPresenter
    with TestMenuPresenterMixin {
  static final String tag = '[test_menu_console]';

  List<String> arguments;

  bool verbose;

  _TestMenuManagerConsole(this.arguments) {
    var parser = ArgParser();
    parser.addFlag('help', abbr: 'h');
    parser.addFlag('verbose', abbr: 'v');

    var results = parser.parse(arguments);
    verbose = (results['verbose'] as bool) || testMenuConsoleDebug;
    if (verbose) {
      stdout.writeln('args: $arguments');
    }
    if (results['help'] as bool) {
      stdout.writeln('Add arguments at the end separated by spaces');
      stdout.writeln('Example to run item 0 and exit');
      stdout.writeln('  dart test_menu.dart 0 -');
      exit(0);
    }

    initialCommands = results.rest;
  }

  // Not null if currently prompting
  Completer<String> promptCompleter;

  TestMenu displayedMenu;
  bool _argumentsHandled = false;

  void _displayMenu(TestMenu menu) {
    displayedMenu = menu;
    //print('- exit');
    for (var i = 0; i < menu.length; i++) {
      final item = menu[i];
      final cmd = item.cmd ?? '$i';
      print('$cmd $item');
    }
  }

  Stream<String> _inCommand;
  StreamSubscription _inCommandSubscription;

  bool done = false;

  void readLine() {
    if (_inCommand == null) {
      // devPrint('readLine setup');
      _inCommand =
          sharedStdIn.transform(utf8.decoder).transform(const LineSplitter());

      // Waiting forever on stdin
      _inCommandSubscription = _inCommand.listen(handleLine);
    }

    //return _inCommand.
  }

  /// Needed when spawning with a process with sharedStdIn
  void freeSharedStdIn() {
    _inCommandSubscription?.cancel();
    _inCommand = null;
  }

  void handleLine(String line) {
    processLine(line).then((_) {
      stdout.write('> ');
    });
  }

  Future processLine(String line) async {
    if (testMenuConsoleDebug) {
      print('$tag Line: $line');
    }

    if (promptCompleter != null) {
      promptCompleter.complete(line);
      //Future done = promptCompleter.future;
      promptCompleter = null;
      //return done;
      return Future.value();
    }
    final menu = displayedMenu;

    // Exit
    if (line == _exitCommand) {
      // print('pop');
      if (!await popMenu()) {
        // New 2020/11/19
        exit(0);
        /*
        // devPrint('should exit?');
        done = true;
        if (_inCommandSubscription != null) {
          await _inCommandSubscription.cancel();
        }*/
      }
      return Future.value();
    }

    // Help
    if (line == _helpCommand) {
      _displayMenu(menu);
      return Future.value();
    }

    final item = menu.byCmd(line);

    var command = menu.command;
    // devPrint('menu.command $command');
    if (item != null) {
      if (verbose) {
        print("$tag running '$item'");
      }

      try {
        await testMenuManager.runItem(item);
      } catch (_) {}
      // return new Future.sync(item.run).then((_) {
      if (verbose) {
        print("$tag done '$item'");
      }
    } else if (command != null) {
      if (verbose) {
        print("$tag running command '$line'");
      }

      try {
        await testMenuManager.runItem(item);
      } catch (_) {}
      // return new Future.sync(item.run).then((_) {
      if (verbose) {
        print("$tag done '$item'");
      }
    } else {
      print('errorValue: $line');
      print('$_exitCommand exit');
      print('$_helpCommand display menu again');
    }

    return Future.value();
  }

//void main() {
//readLine().listen(processLine);
//}

  List<String> initialCommands;
  int initialCommandIndex = 0;

  Future _nextLine([_]) {
    if (initialCommands != null) {
      if (initialCommandIndex < initialCommands.length) {
        final commandLine = initialCommands[initialCommandIndex++];
        return processLine(commandLine).then(_nextLine);
      }
    }
    return Future.value();
  }

  void _handleInput(TestMenu menu) {
    if (menu != displayedMenu) {
      _displayMenu(menu);
    }
    final name = menu.name != null ? '${menu.name} ' : '';
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

  @override
  void write(Object message) {
    stdout.writeln('$message');
  }

  @override
  Future<String> prompt(Object message) {
    //print('$TAG Prompt: $message');
    message ??= 'Enter text';
    stdout.write('$message > ');
    var completer = Completer<String>.sync();
    promptCompleter = completer;
    // read the next line
    _nextLine();
    return completer.future;
  }

  final _interactiveLock = Lock();
  Future<T> subInteractive<T>(Future<T> Function() action) async {
    return await _interactiveLock.synchronized(() async {
      try {
        freeSharedStdIn();
        return await action();
      } finally {
        readLine();
      }
    });
  }
}

void initTestMenuConsole(List<String> arguments) {
  _testMenuManagerConsole = _TestMenuManagerConsole(arguments);
  // set current
  testMenuPresenter = _testMenuManagerConsole;
}

/// To use when releasing stdin is needed
Future<T> usingSharedStdIn<T>(Future<T> Function() action) {
  return _testMenuManagerConsole.subInteractive<T>(action);
}

_TestMenuManagerConsole _testMenuManagerConsole;

/// Main menu declaration
void mainMenu(List<String> arguments, void Function() declare) {
  initTestMenuConsole(arguments);
  declare();
}
