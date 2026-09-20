---
name: tekartik-test-menu-tests
description: >-
  Use when declaring an interactive, manual test menu or debug harness with
  tekartik_test_menu (test.dart, test_menu.dart, key_value.dart,
  test_menu_presenter.dart): test, group, solo_test, solo_group, expect, fail,
  and the re-exported dev_build declarations menu, item, enter, leave,
  enterItem, leaveItem, command, write, writeln, prompt, showMenu, popMenu,
  solo_item, solo_menu, testMenuRun/menuRun, TestMenuManager, KeyValue,
  TestMenuPresenter. Also when picking the platform runner package
  (tekartik_test_menu_io, tekartik_test_menu_node,
  tekartik_test_menu_browser).
---

# Interactive test menus (tekartik_test_menu)

`tekartik_test_menu` declares *manual* tests: a numbered menu where a human
picks what to run. It is a thin layer over the declaration API of
`package:dev_build/menu/menu.dart` (`menu`, `item`, `write`, `prompt`...),
adding `test`/`group`/`expect` aliases so a menu reads like a `package:test`
suite. The package itself is platform agnostic and contains no runner: a
companion package renders the menu on a console, on node or in a browser.

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_test_menu:
      git:
        url: https://github.com/tekartik/test_menu.dart
        path: test_menu
  ```
  In practice you also depend on a runner package for the platform you run
  on: `tekartik_test_menu_io` (`dart run`), `tekartik_test_menu_node` or
  `tekartik_test_menu_browser` (same repo, `path: test_menu_io` /
  `test_menu_node` / `test_menu_browser`). Declare `dev_build` explicitly if
  you import `package:dev_build/menu/menu_io.dart` yourself.

### Imports

* `package:tekartik_test_menu/test_menu.dart` re-exports
  `package:dev_build/menu/menu.dart` — `menu`, `item`, `enter`, `leave`,
  `enterItem`, `leaveItem`, `command`, `write`, `writeln`, `prompt`,
  `showMenu`, `popMenu`, `menuRun`, `solo_item`, `solo_menu`, `devWrite` —
  plus `TestMenuManager` and `testMenuRun()`.
* `package:tekartik_test_menu/test.dart` re-exports everything above, plus
  `package:matcher/matcher.dart` and the package's own `expect`/`fail`, and
  adds `test`, `group`, `solo_test`, `solo_group`.
* `package:tekartik_test_menu/key_value.dart`: `KeyValue` and
  `KeyValueListExt` (prompted configuration values).
* `package:tekartik_test_menu/test_menu_presenter.dart`:
  `TestMenuPresenter`, `TestMenuPresenterMixin`, the `testMenuPresenter`
  setter, to render the menu somewhere else.

### Declaring

* Declarations must be **synchronous**: call `menu`/`item`/`test`/`group`
  from the declaration body, never from inside a running item (use
  `showMenu(() {...})` for a menu built at run time). The body of `menu()`
  and `group()` must be a plain `void Function()`; only item bodies may
  return a `Future` (they are awaited).
* `item(name, body, {cmd, solo})` declares a runnable entry,
  `menu(name, body, {cmd, group, solo})` a sub menu. Items are listed by
  index (`0`, `1`, ...); `cmd: 'a'` gives a word shortcut, `.` leaves the
  current menu, `?` reprints it.
* `test(name, body, {cmd, solo})` is `item` and
  `group(name, body, {solo})` is `menu(..., group: true)`. Use them when the
  menu is a manual test suite; they are interchangeable with `item`/`menu`
  in the same file. `group()` accepts a `cmd` named argument but ignores it —
  use `menu(name, body, cmd: 'x')` when a group needs a shortcut.
* `expect(actual, matcher, {reason, skip})` and `fail(message)` come from
  this package, not from `package:test`: a mismatch throws the package's own
  `TestFailure`, which the menu catches and prints, leaving the menu open.
  All `package:matcher` matchers (`isTrue`, `equals`, `isNotNull`, ...) are
  re-exported by `test.dart`.
* Never import `package:test/test.dart` in a file that imports
  `test.dart`: `test`, `group` and `expect` clash. In a real `package:test`
  file, import `package:tekartik_test_menu/test_menu.dart` instead and use
  `menu`/`item`.
* `solo_test`, `solo_group`, `solo_item`, `solo_menu` (and `solo: true`) run
  only that entry at startup, for a quick debug loop. They are annotated
  `@doNotSubmit`, so the analyzer flags them (`// ignore:
  invalid_use_of_do_not_submit_member`) — remove them before committing. Same
  for `devWrite`.
* Print with `write`/`writeln`, read with `await prompt('message')`; both go
  through the active presenter, `print` does not.

### Running

* This package does not read stdin. A runner package initializes a presenter
  and starts the loop: `mainMenu(args, declare)` /
  `initTestMenuConsole(args)` in `tekartik_test_menu_io`,
  `mainMenuConsole(args, declare)` in `package:dev_build/menu/menu_io.dart`
  (`tekartik_test_menu_io` is a thin wrapper over it), `runMenuConsole` style
  entry points in `tekartik_test_menu_node`, and the browser presenters of
  `tekartik_test_menu_browser`.
* `testMenuRun()` (or `menuRun()`) runs the menu that was just declared,
  once, with the current presenter, and resets the declarer. That is how a
  menu is exercised from an automated `package:test` test; with no presenter
  set, output goes to `print` and `prompt` returns `''`.
* Extra command line arguments are replayed as keystrokes by the console
  runners: `dart run tool/menu.dart 0 1 .` picks item 0, then 1, then quits.
* Keep the declaration in its own platform-agnostic library (importing only
  `test_menu.dart`/`test.dart`) and have one small entry point per platform
  call it. That is how the same menu runs on the console and in a browser.
* `TestMenuManager` (alias of `dev_build`'s `MenuManager`) exposes a static
  `debug` flag (`TestMenuManager.debug.on = true`, deprecated setter, needs
  an `// ignore: deprecated_member_use`) to trace push/pop of menus.

## Examples

### Platform-agnostic menu declaration

```dart
// lib/src/common_menu.dart — shared by every platform entry point.
import 'package:tekartik_test_menu/test_menu.dart';

void declareCommonMenu() {
  menu('main', () {
    item('write hola', () async {
      write('Hola');
    }, cmd: 'a');
    item('echo prompt', () async {
      writeln('RESULT prompt: ${await prompt('Some text then [ENTER]')}');
    });
    item('crash', () {
      throw StateError('crash');
    });
    menu('sub', () {
      enter(() async => writeln('enter sub'));
      leave(() async => writeln('leave sub'));
      item('write hi', () => writeln('hi'));
    }, cmd: 's');
    item('dynamic menu', () async {
      await showMenu(() {
        item('dynamic item', () => write('dynamic'));
        item('back', () => popMenu());
      });
    });
    command((command) {
      writeln('Command entered: $command');
    });
  });
}
```

### Manual test suite with test/group/expect

```dart
// tool/manual_test_menu.dart — run with: dart run tool/manual_test_menu.dart
import 'package:dev_build/menu/menu_io.dart' show mainMenuConsole;
import 'package:tekartik_test_menu/test.dart';

void main(List<String> args) {
  mainMenuConsole(args, () {
    group('parsing', () {
      test('int', () {
        expect(int.tryParse('12'), 12);
      });
      test('bad int', () {
        expect(int.tryParse('oops'), isNull);
      });
    });
    group('network', () {
      enterItem(() => writeln('--- starting'));
      test('slow call', () async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
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

### Prompted configuration values with KeyValue

```dart
import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu/test_menu.dart';

final settings = [KeyValue('url', 'http://localhost:8080'), KeyValue('token', null)];

void declareSettingsMenu() {
  menu('settings', () {
    item('dump', () => settings.dump());
    item('check', () {
      write(settings.valid ? 'all set' : 'some values are missing');
    });
    for (var kv in settings) {
      item('set ${kv.key}', () async {
        kv.value = await prompt('${kv.key} (${kv.value ?? ''})');
        write(kv);
      });
    }
  });
}
```

### Running a declared menu from an automated test

```dart
import 'package:tekartik_test_menu/test_menu.dart';
import 'package:test/test.dart';

void main() {
  test('solo item only runs', () async {
    int? a, b;
    menu('main', () {
      item('regular', () => a = 1);
      // ignore: invalid_use_of_do_not_submit_member
      solo_item('solo', () => b = 2);
    });
    await testMenuRun();
    expect(a, isNull);
    expect(b, 2);
  });
}
```

### Custom presenter

```dart
// Render the menu somewhere else (log, widget, socket...).
import 'package:tekartik_test_menu/test_menu_presenter.dart';

class LogPresenter with TestMenuPresenterMixin implements TestMenuPresenter {
  final lines = <String>[];

  @override
  void presentMenu(DevMenu menu) {
    lines.add('menu ${menu.name}');
  }

  @override
  Future<String> prompt(Object? message) async {
    lines.add('prompt $message');
    return '';
  }

  @override
  void write(Object message) {
    lines.add('$message');
  }
}

void useLogPresenter() {
  testMenuPresenter = LogPresenter();
}
```

## Common mistakes

* Declaring items asynchronously (an `async` `menu()` body, or `item()`
  called from inside a running item): the declaration is collected
  synchronously, use `showMenu` for dynamic menus.
* Importing `package:test/test.dart` next to
  `package:tekartik_test_menu/test.dart` — `test`, `group` and `expect`
  clash.
* Using `print` instead of `write`/`writeln`: it bypasses the presenter and
  is lost on non-console runners.
* Expecting `tekartik_test_menu` alone to show a menu: it declares, a runner
  package (io, node, browser) presents.
* Committing `solo_test`/`solo_group`/`solo_item`/`solo_menu`/`devWrite`;
  they silently skip everything else.
