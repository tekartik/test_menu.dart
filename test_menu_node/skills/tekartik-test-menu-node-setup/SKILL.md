---
name: tekartik-test-menu-node-setup
description: >-
  Use when running a tekartik_test_menu interactive menu on Node.js with
  tekartik_test_menu_node (test_menu_console.dart): mainMenuConsole, the
  re-exported menu/item/enter/leave/command/write/writeln/prompt/showMenu/
  popMenu/solo_item/solo_menu declarations, testMenuRun, TestMenuManager, and
  compiling the bin/ entry point to JavaScript with NodeAppBuilder /
  NodeAppOptions / NodeAppRunOptions from tekartik_app_node_build.
---

# tekartik_test_menu_node: the Node.js runner

`tekartik_test_menu_node` is the Node.js front end of `tekartik_test_menu`:
the same declarations (`menu`, `item`, `prompt`...) presented with a console
built on `tekartik_core_node` (`console.out`, `process.exit`) and
`tekartik_stdio_node` (`readline.question`). The menu runs after the Dart
entry point has been compiled to JavaScript and started with `node`.

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_test_menu_node:
      git:
        url: https://github.com/tekartik/test_menu.dart
        path: test_menu_node
  dev_dependencies:
    tekartik_app_node_build:
      git:
        url: https://github.com/tekartik/app_node_utils.dart
        path: app_build
  ```
  It brings `tekartik_test_menu` (same repo, `path: test_menu`); declare it
  explicitly when a shared declaration library imports
  `package:tekartik_test_menu/test_menu.dart` or `test.dart`.

### Imports and entry point

* `package:tekartik_test_menu_node/test_menu_console.dart` is the single
  public library. It exports `package:tekartik_test_menu/test_menu.dart`
  (hence `menu`, `item`, `enter`, `leave`, `enterItem`, `leaveItem`,
  `command`, `write`, `writeln`, `prompt`, `showMenu`, `popMenu`,
  `solo_item`, `solo_menu`, `menuRun`, `testMenuRun`, `TestMenuManager`) and
  adds `mainMenuConsole(arguments, declare)`.
* `mainMenuConsole` installs the node presenter and then calls the
  **synchronous** `declare` callback. There is no `mainMenu`,
  `initTestMenuConsole` or `usingSharedStdIn` here: those belong to
  `tekartik_test_menu_io`. Spawning a child process that reads the keyboard
  is not supported by this runner.
* For a manual test suite, import `package:tekartik_test_menu/test.dart`
  next to it and declare with `test`/`group`/`expect`; never import
  `package:test/test.dart` in that same file.
* Put the entry point in `bin/` (default source directory of the node
  builder), keep the declarations in a platform-agnostic library importing
  only `package:tekartik_test_menu/test_menu.dart` so the same menu can also
  run on io or in the browser.

### Console behaviour

* Items are listed `0 name`, `1 name`, ... `cmd: 'a'` names an item; `.`
  leaves the current menu and calls `process.exit(0)` at the top level, `?`
  reprints the menu. Errors thrown by an item are swallowed and the menu
  stays open.
* Extra command line arguments are replayed as typed commands, so
  `node deploy/simple_menu.js 0 .` runs item 0 and exits. `-h` prints the
  hint and exits, `-v` traces each command. Without a trailing `.` the
  process keeps waiting on `readline`.
* `write`/`writeln` go to `console.out`; `prompt(message)` is answered by the
  next line read by `readline`. Plain `print` also works on node but bypasses
  the presenter.

### Build and run

* Compile and run in one step with `tekartik_app_node_build`:
  `NodeAppBuilder(options: NodeAppOptions(srcFile: 'simple_menu.dart'))`
  then `await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin))`
  (`stdin` from `package:process_run/stdio.dart`). `srcDir` defaults to
  `bin`, `srcFile` to `main.dart`, `deployDir` to `deploy`; the compiled
  `deploy/<basename>.js` is what `node` runs. Passing the parent `stdin` is
  what makes the menu interactive.
* `builder.compile()`, `builder.run(runOptions: ...)` and `builder.clean()`
  are the separate steps. Run these `tool/` scripts with `dart run`.
* `node` must be installed; the compiled JavaScript, not the Dart file, is
  the thing to start.
* In automated tests use `testMenuRun()`, which runs the declared menu once
  without the node presenter, so the test also passes on the VM
  (`@TestOn('vm || node')`).

## Examples

### Node menu entry point

```dart
// bin/simple_menu.dart — compiled to deploy/simple_menu.js
import 'package:tekartik_test_menu_node/test_menu_console.dart';

Future<void> main(List<String> arguments) async {
  mainMenuConsole(arguments, () {
    item('write hola', () async {
      write('Hola');
    });
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text then [ENTER]')}');
    });
    item('crash', () {
      throw StateError('crash');
    });
    menu('sub', () {
      enter(() async => writeln('enter sub'));
      leave(() async => writeln('leave sub'));
      item('write hi', () => write('hi'));
    }, cmd: 's');
    menu('handle command', () {
      command((command) {
        write('Got command: $command');
      });
      item('write hola', () => write('Hola'));
    });
    item('dynamic menu', () async {
      await showMenu(() {
        item('dynamic item', () => write('dynamic'));
        item('back', () => popMenu());
      });
    });
  });
}
```

### Compile and run it on Node.js

```dart
// tool/build_and_run_simple_menu.dart — dart run tool/build_and_run_simple_menu.dart
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_node_build/app_build.dart';

Future<void> main() async {
  var builder = NodeAppBuilder(
    options: NodeAppOptions(srcFile: 'simple_menu.dart'),
  );
  await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin));
}
```

### Manual test suite on node

```dart
// bin/manual_tests.dart
import 'package:tekartik_test_menu/test.dart';
import 'package:tekartik_test_menu_node/test_menu_console.dart';

void main(List<String> arguments) {
  mainMenuConsole(arguments, () {
    group('storage', () {
      test('write then read', () async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(true, isTrue);
      });
      test('needs a token', () async {
        var token = await prompt('Token');
        if (token.isEmpty) {
          fail('no token given');
        }
        expect(token, isNotEmpty);
      });
    });
  });
}
```

### Shared declaration reused by the node entry point

```dart
// lib/src/common_menu.dart — no dart:io, no node import.
import 'package:tekartik_test_menu/test_menu.dart';

void declareCommonMenu() {
  menu('main', () {
    item('write hola', () => write('Hola'));
    item('echo prompt', () async {
      writeln('RESULT prompt: ${await prompt()}');
    });
  });
}
```

### Automated test of a declared menu

```dart
@TestOn('vm || node')
library;

import 'package:tekartik_test_menu_node/test_menu_console.dart';
import 'package:test/test.dart';

void main() {
  test('solo item only', () async {
    int? a, b;
    menu('main', () {
      item('regular', () => a = 1);
      menu('sub', () {
        // ignore: invalid_use_of_do_not_submit_member
        solo_item('solo', () => b = 2);
      });
    });
    await testMenuRun();
    expect(a, isNull);
    expect(b, 2);
  });
}
```

## Common mistakes

* Running the Dart file directly on the VM: this runner needs the Node.js
  `readline`/`console` bindings, compile it first.
* Looking for `mainMenu`, `initTestMenuConsole`, `usingSharedStdIn` or the
  `key_value_io.dart` env helpers here: they are `tekartik_test_menu_io`
  only.
* Omitting `NodeAppRunOptions(stdin: stdin)`: the compiled menu starts but
  never receives a keystroke.
* Forgetting the trailing `.` when passing commands as arguments.
* Importing `package:test/test.dart` together with
  `package:tekartik_test_menu/test.dart` (`test`, `group`, `expect` clash).
* Declaring items from inside a running item instead of `showMenu`.
