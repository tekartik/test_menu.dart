# tekartik_test_menu_example

Starters and examples of [tekartik_test_menu](../test_menu) manual menus.

## Starters to copy

| Folder | Runner | Run |
|---|---|---|
| `starter_web` | web page (`test_menu_web.dart`, `package:web`) | `webdev serve starter_web:8080` |
| `starter_universal` | web page or console, same file (`mainMenuUniversal`) | `webdev serve starter_universal:8080`, `dart run starter_universal/main.dart` |
| `starter_io` | console (`tekartik_test_menu_io`) | `dart run starter_io/test_menu.dart` |
| `starter_browser` | deprecated `dart:html` compat library (no wasm) | `webdev serve starter_browser:8080` |
| `starter_browser_mdl` | deprecated MDL entry point, now the web page menu | `webdev serve starter_browser_mdl:8080` |

`webdev` serves a folder with `build_runner` (`dart pub global activate
webdev`). `starter_web`, `starter_browser` and `starter_browser_mdl` also
load their `test_menu.js` for the `js console.log` item.

## Examples

* `lib/test_menu_io_simple.dart`, `lib/test_menu_io_solo.dart` (a
  `solo_item`), `lib/test_menu_io_interactive_tests.dart` (prompt, a slow
  `enter`/`leave`, 250 lines, spawning the menu again): console,
  `dart run lib/<file>`.
* `starter_io/test_group.dart`: a `solo_test` that fails on purpose.
* `lib/test_menu_def_console_interactive_tests.dart`,
  `lib/test_menu_def_mdl_browser_interactive_tests.dart`: menus built as
  `TestMenu` objects and pushed (`pushMenu`, an internal API). Their items do
  nothing with dev_build 1.2.2 (a null check in its `getRunner`, swallowed by
  the console); declare menus with `menu`/`item` instead.

Arguments are typed commands: `dart run lib/test_menu_io_simple.dart 0 .`
enters `main` and leaves it, `.` at the top exits.
