---
name: tekartik-test-menu-io-setup
description: >-
  Use when running a tekartik_test_menu interactive menu as a dart:io console
  script with tekartik_test_menu_io (test_menu_io.dart, key_value_io.dart):
  mainMenu, initTestMenuConsole, testMenuRun, usingSharedStdIn, the
  re-exported menu/item/test/group/write/writeln/prompt/showMenu/popMenu
  declarations, and the env-var helpers keyValuesMenu, KeyValue, kvFromEnv,
  fromEnv, promptToEnv, setToEnv, deleteFromEnv, getEnvVar, setEnvVar,
  deleteEnvVar. Also when scripting a menu from the command line arguments.
---

# tekartik_test_menu_io: the console runner

`tekartik_test_menu_io` is the `dart:io` front end of `tekartik_test_menu`:
it installs a console presenter that prints the numbered menu on stdout and
reads choices on stdin, and it adds helpers that persist prompted values as
`process_run` environment variables. It is a thin wrapper over
`package:dev_build/menu/menu_io.dart`.

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_test_menu_io:
      git:
        url: https://github.com/tekartik/test_menu.dart
        path: test_menu_io
  ```
  It brings `tekartik_test_menu` (same repo, `path: test_menu`); declare it
  explicitly too when a shared, platform-agnostic declaration library imports
  `package:tekartik_test_menu/test_menu.dart` or `test.dart`.

### Imports and entry point

* `package:tekartik_test_menu_io/test_menu_io.dart` is the only import a
  console script needs: it re-exports `package:tekartik_test_menu/test_menu.dart`
  and `package:dev_build/menu/menu_io.dart` (so `menu`, `item`, `enter`,
  `leave`, `enterItem`, `leaveItem`, `command`, `write`, `writeln`, `prompt`,
  `showMenu`, `popMenu`, `solo_item`, `solo_menu`, `menuRun`,
  `initMenuConsole`, `mainMenuConsole`), plus `usingSharedStdIn` and
  `package:tekartik_common_utils/common_utils_import.dart`.
* Start the menu with `mainMenu(arguments, declare)` — it calls
  `initTestMenuConsole(arguments)` (the console presenter) then the
  synchronous `declare` callback. `mainMenuConsole` is the same function from
  `dev_build`. Use `initTestMenuConsole(arguments)` alone when the
  declarations come from another library called afterwards.
* `testMenuRun()` / `menuRun()` runs the declared menu once without
  installing the console presenter (automated tests).
* For a manual test suite add `package:tekartik_test_menu/test.dart` next to
  `test_menu_io.dart` and declare with `test`/`group`/`expect`; do not import
  `package:test/test.dart` in the same file.

### Console behaviour

* Items are listed `0 name`, `1 name`, ... `cmd: 'a'` names an item; `.`
  leaves the current menu (and exits at the top level), `?` reprints it.
* Extra command line arguments are replayed as typed commands:
  `dart run tool/menu.dart 0 s 1 .` picks item 0, enters menu `s`, runs item 1
  and exits. `-h` prints that hint and exits, `-v` echoes the arguments.
  Always end a scripted run with `.`, otherwise the process waits on stdin.
* An exception thrown by an item is caught and printed; the menu stays open.
* The script keeps `sharedStdIn` (`package:process_run/shell.dart`) open. To
  run a child process that needs the terminal, wrap it in
  `await usingSharedStdIn(() async {...})` and pass `stdin: sharedStdIn` to
  the `Shell`, otherwise the menu and the child fight over stdin.
* Menus meant to be run by hand belong in `tool/` or `example/`, not in
  `test/`: they never terminate on their own.

### Environment values (key_value_io.dart)

* `package:tekartik_test_menu_io/key_value_io.dart` exports `KeyValue` and
  `KeyValueListExt` (`.valid`, `.dump()`) plus the io-only extensions.
* `'MY_VAR'.kvFromEnv(defaultValue: '...')` builds a `KeyValue` from the
  current shell environment; `'MY_VAR'.fromEnv(defaultValue: '...')` returns
  the raw `String?`.
* On a `KeyValue`: `await kv.promptToEnv()` prompts (showing the current
  value) and saves a non-empty answer, `await kv.setToEnv(value)` and
  `await kv.deleteFromEnv()` write/erase it. All three update `kv.value`.
* `keyValuesMenu('vars', [kv1, kv2])` declares a ready-made sub menu:
  `dump`, `all` (prompt each), `prompt invalids`, one `update <key>` item per
  value (grouped under a `one by one` sub menu when there are 6 or more) and
  `clear one by one`.
* `setEnvVar(key, value)`, `deleteEnvVar(key)` and `getEnvVar(key)` wrap
  `process_run`'s shell environment: values are **persisted** in the local
  env file of the current directory by default, or in the user env file with
  `user: true` (the local value wins when both exist). They are not
  `Platform.environment` variables and survive across runs; use throwaway key
  names in tests and delete them afterwards.
* Prompted values are saved in clear text — never store a real secret with
  `promptToEnv`.
* The list extension `promptToEnv({ifInvalid})` used by `keyValuesMenu` is
  internal; loop over the values and call `kv.promptToEnv()` yourself.

## Examples

### Console menu script

```dart
// tool/menu.dart — dart run tool/menu.dart
import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  mainMenu(args, () {
    command((command) {
      writeln('Command entered: $command');
    });
    menu('main', () {
      item('write hola', () async {
        write('Hola');
      }, cmd: 'a');
      item('echo prompt', () async {
        writeln('RESULT prompt: ${await prompt('Some text then [ENTER]')}');
      });
      menu('sub', () {
        enter(() async => writeln('enter sub'));
        leave(() async => writeln('leave sub'));
        item('print hi', () => writeln('hi'));
      }, cmd: 's');
      item('custom menu', () async {
        await showMenu(() {
          item('custom item', () => write('custom'));
          item('back', () => popMenu());
        });
      });
    });
  });
}
```

### Manual test suite on the console

```dart
// tool/manual_tests.dart
import 'package:tekartik_test_menu/test.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  mainMenu(args, () {
    group('local server', () {
      test('ping', () async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(true, isTrue);
      });
      test('token', () async {
        var token = await prompt('Token');
        expect(token, isNotEmpty);
      });
    });
  });
}
```

### Prompted, persisted configuration

```dart
// tool/config_menu.dart
import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

var apiUrl = 'MY_API_URL'.kvFromEnv(defaultValue: 'http://localhost:8080');
var apiUser = 'MY_API_USER'.kvFromEnv();

Future<void> main(List<String> args) async {
  mainMenu(args, () {
    keyValuesMenu('vars', [apiUrl, apiUser]);
    item('dump', () => [apiUrl, apiUser].dump());
    item('call api', () async {
      if (![apiUrl, apiUser].valid) {
        write('missing configuration, use the vars menu');
        return;
      }
      write('calling ${apiUrl.value} as ${apiUser.value}');
    });
    item('set url to localhost', () async {
      await apiUrl.setToEnv('http://localhost:8080');
      write(apiUrl);
    });
    item('forget user', () async {
      await apiUser.deleteFromEnv();
      write(apiUser);
    });
  });
}
```

### Running a child process that needs the terminal

```dart
// tool/spawn_menu.dart
import 'package:process_run/shell.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  mainMenu(args, () {
    item('run the analyzer', () async {
      await usingSharedStdIn(() async {
        await Shell(stdin: sharedStdIn).run('dart analyze');
      });
    });
  });
}
```

### Automated test of a declared menu

```dart
@TestOn('vm')
library;

import 'package:tekartik_test_menu_io/test_menu_io.dart';
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

### Read or write an env var directly

```dart
import 'package:tekartik_test_menu_io/key_value_io.dart';

Future<void> main() async {
  await setEnvVar('MY_VAR', 'local value'); // local env file
  await setEnvVar('MY_VAR', 'user value', user: true); // user env file
  var value = getEnvVar('MY_VAR'); // 'local value', the local one wins
  await deleteEnvVar('MY_VAR');
  await deleteEnvVar('MY_VAR', user: true);
}
```

## Common mistakes

* Putting an interactive menu in `test/`: `dart test` hangs, it never exits.
* Forgetting the trailing `.` when scripting items from the command line.
* Spawning a process without `usingSharedStdIn`/`sharedStdIn`: the menu keeps
  swallowing the keystrokes meant for the child.
* Importing `package:test/test.dart` together with
  `package:tekartik_test_menu/test.dart` (`test`, `group`, `expect` clash).
* Expecting `getEnvVar`/`setEnvVar` to touch `Platform.environment`: they
  read and write the `process_run` local/user env files.
* Declaring items from inside a running item instead of `showMenu`.
