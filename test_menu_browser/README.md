# tekartik_test_menu_browser

A manual test menu in a web page: the items and sub menus declared with
[tekartik_test_menu](../test_menu) shown as a console (output log, clickable
menu, command line, prompts), to run code by hand in a real browser. The
same declaration also runs on the console (`dart run`) through
`test_menu_universal.dart`.

Browser (dart2js and dart2wasm, `webdev serve`, `dart compile wasm`); the
universal entry point also runs on the Dart VM.

## Getting started

Not on pub.dev, a git dependency:

```yaml
dependencies:
  tekartik_test_menu_browser:
    git:
      url: https://github.com/tekartik/test_menu.dart
      path: test_menu_browser
dev_dependencies:
  build_runner: ">=2.15.0"
  build_web_compilers: ">=4.4.19"
```

`web/main.dart`, served with `webdev serve web:8080`:

```dart
import 'package:tekartik_test_menu_browser/test_menu_web.dart';

Future<void> main() async {
  await mainMenuWeb(() {
    item('hello', () => write('Hello'));
    item('ask', () async {
      var name = await prompt('Your name');
      write('Hello $name');
    });
    menu('sub menu', () {
      item('crash', () => throw StateError('crash'));
    });
  });
}
```

`web/index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>my test menu</title>
  <script defer src="main.dart.js"></script>
</head>
<body></body>
</html>
```

Click an item or type its number in the command line (`-` back, `?` help).
Running an item sets the location hash: reloading the page runs it again.

## Which library

* `test_menu_web.dart`: browser only, `mainMenuWeb(declare)`,
  `initTestMenuBrowser({jsFiles, prefs})`, `TestMenuManagerBrowser`.
* `test_menu_universal.dart`: `await mainMenu(arguments, declare)`, the web
  console in a browser, the `tekartik_test_menu_io` console on the VM.
* `key_value_universal.dart` (`'MY_VAR'.kvFromVar()`, `keyValuesMenu`: local
  storage in a browser, env files on the VM) or `key_value_web.dart`
  (`kvFromLocalStorage`). Values are stored in clear text.
* `test_menu_browser.dart` is `test_menu_web.dart` plus
  `tekartik_test_menu`; the `test_menu_mdl_browser*` and
  `test_menu_browser_compat.dart` libraries are deprecated (the MDL ones run
  the web menu, the compat one still uses `dart:html`).

## Good to know

* Await `mainMenuWeb`, `mainMenu` or `initTestMenuBrowser()` before declaring.
  Call `initTestMenuBrowser` once: a second call adds a second console.
* `<meta charset="UTF-8">` in the page: ddc keeps non ascii characters as is.
* Add `<div id="tekartik_test_menu_container"></div>` to place the console,
  otherwise it is appended to the body.
* Open the page with `?agent` to drive it from an LLM agent (the `app-agent`
  MCP `menu` and `menu_line` tools), `?debug` for the menu traces.
* Answer a prompt before running another item: a second prompt replaces the
  first one, which then never completes.
* An interactive menu never ends: keep it in `web/` or `example/`, not in
  `test/`.

A starter to copy: `starter_universal` of
[test_menu_example](../test_menu_example). More (the page, key values,
agent, testing): the
[skill](skills/tekartik-test-menu-browser-setup/SKILL.md) and the
[examples](example).
