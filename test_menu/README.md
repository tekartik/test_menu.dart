# tekartik_test_menu

Manual test menus for Dart programs: you declare menus and items (or
`group`/`test`, like a `package:test` file), a runner shows them as a
numbered list and runs the one picked (on a console, in a browser page, on
node or in a Flutter app). For the tests a human runs and looks at: a
device, a server, a slow or interactive scenario.

This package declares, it does not show anything: it is the platform
agnostic layer over `package:dev_build/menu/menu.dart`. Not on pub.dev, use
git dependencies.

## Getting started (console)

```yaml
dependencies:
  tekartik_test_menu:
    git:
      url: https://github.com/tekartik/test_menu.dart
      path: test_menu
  # The console runner (dart run).
  tekartik_test_menu_io:
    git:
      url: https://github.com/tekartik/test_menu.dart
      path: test_menu_io
```

```dart
// tool/my_menu.dart, run with: dart run tool/my_menu.dart
import 'package:tekartik_test_menu/test.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart' show mainMenu;

void main(List<String> arguments) {
  mainMenu(arguments, () {
    group('parsing', () {
      test('int', () {
        expect(int.tryParse('12'), 12);
      });
      test('ask', () async {
        var name = await prompt('Your name');
        write('Hello $name');
      });
    });
    item('say hi', () => write('hi'), cmd: 'h');
  });
}
```

Type the number (or the `cmd`) of an item, `.` to go back (or exit), `?` to
show the menu again. The arguments are the first lines typed:
`dart run tool/my_menu.dart 0 0 . .` enters `parsing`, runs `int`, goes back
and exits.

## Platforms and runners

| Platform | Runner package (same repository) | Entry point |
|---|---|---|
| console (`dart run`) | `tekartik_test_menu_io` (`path: test_menu_io`) | `mainMenu(arguments, declare)` |
| browser | `tekartik_test_menu_browser` (`path: test_menu_browser`) | `await initTestMenuBrowser()`, then declare |
| node | `tekartik_test_menu_node` (`path: test_menu_node`) | `mainMenuConsole(arguments, declare)` (`test_menu_console.dart`) |
| Flutter | `tekartik_test_menu_flutter` ([test_menu_flutter](https://github.com/tekartik/test_menu_flutter)) | `mainMenuFlutter(declare)` |

`package:dev_build/menu/menu_io.dart`'s `mainMenuConsole` is the same
console as `mainMenu`. Keep the declarations in a platform agnostic library
(importing only `tekartik_test_menu`) and call them from one small entry
point per platform. Starters: `test_menu_example/starter_io`,
`starter_web`, `starter_browser`.

## Libraries

| Import | Gives |
|---|---|
| `package:tekartik_test_menu/test_menu.dart` | `menu`, `item`, `enter`, `leave`, `enterItem`, `leaveItem`, `command`, `write`, `writeln`, `prompt`, `showMenu`, `popMenu`, `solo_item`, `solo_menu`, `menuRun` (dev_build) |
| `package:tekartik_test_menu/test.dart` | the above, `test`/`group` (an item, a sub menu), `solo_test`, `solo_group`, `expect`, `fail` and the `package:matcher` matchers |
| `package:tekartik_test_menu/key_value.dart` | `KeyValue`: values prompted once (a url, a token) |
| `package:tekartik_test_menu/test_menu_presenter.dart` | `TestMenuPresenter` to show the menu somewhere else |
| `package:tekartik_test_menu/test_menu_agent.dart` | `testMenuAgentInit()`: let an LLM agent drive the menu (VM service, or `window.tekartikAgent` with `?agent` on the web) |

## Common mistakes

* Importing `package:test/test.dart` in a file that imports
  `tekartik_test_menu/test.dart`: `test`, `group` and `expect` clash. In a
  real `package:test` file use `test_menu.dart` (`menu`/`item`).
* Declaring from a running item, or an `async` group body: declarations are
  synchronous, use `showMenu(() {...})` for a menu built at run time.
* The async matchers of `package:matcher/expect.dart` (`throwsA`,
  `completion`...) do not work with this `expect`: catch the error, or
  `await` the future, then `expect` the value.
* Piping the input of a console menu (`printf '0\n' | dart run
  tool/my_menu.dart`): when the input ends while an item prompts, the
  program ends (exit code 0). Pass the lines as arguments instead.
* `print` instead of `write`/`writeln`: it bypasses the presenter (lost in
  a browser or Flutter runner, not seen by an agent).
* Committing a `solo_test`/`solo_item`: only that entry runs at start.

The `tekartik-test-menu-tests` skill (`skills/`) has more examples.
