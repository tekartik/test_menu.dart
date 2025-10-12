library;

import 'package:args/args.dart';
import 'package:dev_build/src/import.dart';
//import 'package:dev_build/src/menu/dev_menu.dart';
//import 'package:dev_build/src/menu/menu_manager.dart';
import 'package:dev_build/src/menu/presenter_mixin.dart';

//import 'package:process_run/stdio.dart' hide stdin;
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_core_node/console.dart';
import 'package:tekartik_core_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

// ignore_for_file: implementation_imports

// set to false before checkin
/// Debug (internal)
bool menuConsoleDebug = false; //devWarning(true); // false;

String _exitCommand = '.';
String _helpCommand = '?';

class _MenuManagerConsole extends MenuPresenter with MenuPresenterMixin {
  static final String tag = '[test_menu_console]';

  List<String> arguments;

  late bool verbose;

  _MenuManagerConsole(this.arguments) {
    var parser = ArgParser();
    parser.addFlag('help', abbr: 'h');
    parser.addFlag('verbose', abbr: 'v');

    var results = parser.parse(arguments);
    verbose = (results['verbose'] as bool) || menuConsoleDebug;
    if (verbose) {
      console.out.writeln('args: $arguments');
    }
    if (results['help'] as bool) {
      console.out.writeln('Add arguments at the end separated by spaces');
      console.out.writeln('Example to run item 0 and exit');
      console.out.writeln('  dart test_menu.dart 0 -');
      process.exit(0);
    }

    initialCommands = results.rest;
  }

  // Not null if currently prompting
  Completer<String>? promptCompleter;

  DevMenu? displayedMenu;
  bool _argumentsHandled = false;

  void _displayMenu(DevMenu menu) {
    displayedMenu = menu;
    //print('- exit');
    for (var i = 0; i < menu.length; i++) {
      final item = menu[i];
      final cmd = item.cmd ?? '$i';
      console.out.writeln('$cmd $item');
    }
  }

  var _readLoopSetup = false;
  bool done = false;

  void readLine() {
    if (!_readLoopSetup) {
      _readLoopSetup = true;
      // devPrint('readLine setup');
      () async {
        while (true) {
          var line = await readline.question('');
          handleLine(line);

          /*
          _inCommand = sharedStdIn
              .transform(utf8.decoder)
              .transform(const LineSplitter());

          // Waiting forever on stdin
          _inCommandSubscription = _inCommand!.listen(handleLine);*/
        }
      }();

      //return _inCommand.
    }
  }

  /// Needed when spawning with a process with sharedStdIn
  void freeSharedStdIn() {}

  void handleLine(String line) {
    processLine(line).then((_) {
      console.out.writeln('> ');
    });
  }

  Future processLine(String line) async {
    if (menuConsoleDebug) {
      console.out.writeln('$tag Line: $line');
    }

    var currentPromptCompleter = promptCompleter;
    if (currentPromptCompleter != null) {
      // since it is a async controller, make sure to set it no null first
      promptCompleter = null;
      currentPromptCompleter.complete(line);
      return Future.value();
    }
    final menu = displayedMenu;

    // Exit
    if (line == _exitCommand) {
      // print('pop');
      if (!await popMenu()) {
        // New 2020/11/19
        process.exit(0);
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
      _displayMenu(menu!);
      return Future.value();
    }

    final item = menu!.byCmd(line);

    var command = menu.command;
    // devPrint('menu.command $command');
    if (item != null) {
      if (verbose) {
        console.out.writeln("$tag running '$item'");
      }

      try {
        await menuManager.runItem(item);
      } catch (_) {}
      // return new Future.sync(item.run).then((_) {
      if (verbose) {
        console.out.writeln("$tag done '$item'");
      }
    } else if (command != null) {
      if (verbose) {
        console.out.writeln("$tag running command '$line'");
      }

      try {
        await command.fn(line);
      } catch (_) {}
      // return new Future.sync(item.run).then((_) {
      if (verbose) {
        console.out.writeln("$tag done '$command'");
      }
    } else {
      console.out.writeln('errorValue: $line');
      console.out.writeln('$_exitCommand exit');
      console.out.writeln('$_helpCommand display menu again');
    }

    return Future.value();
  }

  //void main() {
  //readLine().listen(processLine);
  //}

  List<String>? initialCommands;
  int initialCommandIndex = 0;

  Future _nextLine([_]) {
    if (initialCommands != null) {
      if (initialCommandIndex < initialCommands!.length) {
        final commandLine = initialCommands![initialCommandIndex++];
        return processLine(commandLine).then(_nextLine);
      }
    }
    return Future.value();
  }

  void _handleInput(DevMenu menu) {
    if (menu != displayedMenu) {
      _displayMenu(menu);
    }
    final name = '${menu.name} ';
    console.out.writeln('$name> ');

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
  void presentMenu(DevMenu menu) {
    _handleInput(menu);

    processMenu(menu);
  }

  @override
  void write(Object message) {
    console.out.writeln('$message');
  }

  @override
  Future<String> prompt(Object? message) {
    //print('$TAG Prompt: $message');
    message ??= 'Enter text';
    console.out.writeln('$message > ');
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

/// Initialize the test menu console.
void initMenuConsoleImpl(List<String> arguments) {
  _menuManagerConsole = _MenuManagerConsole(arguments);
  // set current
  menuPresenter = _menuManagerConsole!;
}

/// To use when releasing stdin is needed
Future<T> usingSharedStdIn<T>(Future<T> Function() action) {
  return _menuManagerConsole!.subInteractive<T>(action);
}

_MenuManagerConsole? _menuManagerConsole;

/// Main menu declaration
void mainMenuConsole(List<String> arguments, void Function() declare) {
  initMenuConsoleImpl(arguments);
  declare();
}
