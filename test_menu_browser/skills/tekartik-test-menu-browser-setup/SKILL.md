---
name: tekartik-test-menu-browser-setup
description: >-
  Use when running a tekartik_test_menu interactive menu in a web page, or on
  both the browser and the console, with tekartik_test_menu_browser
  (test_menu_universal.dart, test_menu_web.dart, test_menu_browser.dart,
  key_value_universal.dart, key_value_web.dart, key_value_browser.dart):
  mainMenu, mainMenuUniversal, mainMenuWeb, initTestMenuBrowser,
  TestMenuManagerBrowser, testMenuBrowserContainerId, testMenuLoadJs, jsTest,
  keyValuesMenu, kvFromVar, kvFromLocalStorage, promptToVar,
  promptToLocalStorage, getVar/setVar/deleteVar, and serving or testing the
  page with webdev, dart test -p chrome or dart compile wasm.
---

# tekartik_test_menu_browser: the web runner

`tekartik_test_menu_browser` presents a `tekartik_test_menu` declaration as a
clickable list in a web page: `initTestMenuBrowser()` installs a
`TestMenuManagerBrowser` presenter that renders the menu into a `<div>`,
prints `write` output into a `<pre>` and answers `prompt` from an `<input>`.
Its `test_menu_universal.dart` library runs the *same* menu on the console
(`dart run`) and in the browser through conditional imports.

## Guidelines

* Dependency (git, not published on pub.dev):
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
  It brings `tekartik_test_menu` and `tekartik_test_menu_io` (same repo);
  declare `tekartik_test_menu` explicitly when a shared declaration library
  imports `package:tekartik_test_menu/test_menu.dart`.

### Which library to import

* `package:tekartik_test_menu_browser/test_menu_universal.dart` — the
  default. Re-exports `package:tekartik_test_menu/test.dart` and
  `test_menu.dart` (so `menu`, `item`, `test`, `group`, `expect`, `write`,
  `writeln`, `prompt`, `showMenu`, `popMenu`, `enter`, `leave`, `command`...)
  and adds `Future<void> mainMenu(arguments, declare)` /
  `mainMenuUniversal(arguments, declare)`. A conditional import picks the
  browser presenter when compiled to JS/wasm and the
  `tekartik_test_menu_io` console presenter on the Dart VM. **Await it.**
* `package:tekartik_test_menu_browser/test_menu_web.dart` (or the equivalent
  `test_menu_browser.dart`) — browser only: `initTestMenuBrowser({jsFiles})`,
  `mainMenuWeb(declare)`, the one-argument compat `mainMenu(declare)`,
  `TestMenuManagerBrowser`, `testMenuBrowserContainerId`, `testMenuLoadJs`,
  `jsTest(name)`. Importing it in VM code fails at compile time (it uses
  `package:web`).
* Never import `test_menu_universal.dart` and `test_menu_web.dart` in the
  same file: both define `mainMenu` with different signatures
  (`(arguments, declare)` vs `(declare)`).
* `test_menu_mdl_browser.dart`, `test_menu_mdl_browser_compat.dart` and
  `test_menu_browser_compat.dart` are `@Deprecated` legacy (`dart:html`,
  Material Design Lite). Do not use them in new code.
* Keep the declarations in a platform-agnostic library that imports only
  `package:tekartik_test_menu/test_menu.dart`, and add one thin entry point
  per platform (`web/main.dart`, `tool/menu.dart`).

### The page

* Serve the entry point with `webdev serve web:8080` (needs
  `build_web_compilers`) or `dart run build_runner serve`. A matching
  `.html` file must load the compiled script, for example
  `<script defer src="main.dart.js"></script>`.
* Add `<div id="tekartik_test_menu_container"></div>` (the value of
  `testMenuBrowserContainerId`) where the menu should appear; without it a
  `<div>` is appended to `<body>`.
* `initTestMenuBrowser` loads
  `packages/tekartik_test_menu_browser/css/test_menu_web.css` (failure is
  logged, not fatal) and can load extra scripts first:
  `await initTestMenuBrowser(jsFiles: ['my_lib.js'])`, then call a global
  JavaScript function with `jsTest('myGlobalFunction')`.
* Running an item sets `window.location.hash` to the item path, and
  `initTestMenuBrowser` replays that hash on startup: **reloading the page
  re-runs the last item**, which is the intended edit/reload loop. Adding
  `?debug` to the url turns on the menu manager traces.
* `write`/`writeln` append to a bounded output buffer (100 lines) shown in a
  `<pre>`; `prompt` waits for a `change` event on the input field.
* Wasm: `dart compile wasm web/main.dart -o build/wasm/main.wasm` then serve
  that directory (see `tool/build_wasm.dart`, `tool/run_wasm.dart`).

### Key values

* Universal — `package:tekartik_test_menu_browser/key_value_universal.dart`:
  `'MY_VAR'.kvFromVar(defaultValue: '...')` builds a `KeyValue`,
  `'MY_VAR'.fromVar()` reads the raw `String?`, `setVar`/`getVar`/
  `deleteVar` are the raw accessors, and on a `KeyValue`: `await kv.set(v)`
  (null deletes), `await kv.delete()`, `kv.get()`, `await kv.promptToVar()`.
  Storage is `localStorage` in the browser and the `process_run` env files on
  the VM, so the same menu keeps its settings on both.
* Browser only — `key_value_web.dart` (or `key_value_browser.dart`, which
  adds the deprecated `getLocalStorageVar`/`setLocalStorageVar`/
  `deleteLocalStorageVar`): `'MY_VAR'.kvFromLocalStorage(defaultValue: ...)`,
  `'MY_VAR'.fromLocalStorage()`, `await kv.promptToLocalStorage()`.
  `fromLocalStorage` caches the first read for the lifetime of the page.
* `keyValuesMenu('vars', [kv1, kv2])` (defined in both libraries, import only
  one) declares a sub menu with `dump`, `all`, `prompt invalids`, one
  `update <key>` item per value (under a `one by one` sub menu from 6 values
  up) and `clear one by one`.
* `KeyValue` also offers `.value`, `.valid`, and on a list `.valid` and
  `.dump()`. Values are stored in clear text: never a real secret.

### Testing

* `dart test -p chrome` runs the `package:test` suites in a browser;
  `dart_test.yaml` with `platforms: [vm, chrome]` runs both. The universal
  key value helpers are what such a test exercises — use throwaway key names
  and delete them.
* Interactive menus themselves belong in `web/` or `example/`, never in
  `test/`: they never terminate.

## Examples

### Universal entry point (browser and console)

```dart
// web/main.dart — webdev serve web:8080, or dart run web/main.dart
import 'package:tekartik_test_menu_browser/key_value_universal.dart';
import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

var apiUrl = 'MY_API_URL'.kvFromVar(defaultValue: 'http://localhost:8080');

Future<void> main(List<String> arguments) async {
  await mainMenu(arguments, () {
    keyValuesMenu('vars', [apiUrl]);
    item('write hola', () async {
      write('Hola');
    });
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text then [ENTER]')}');
    });
    menu('sub', () {
      enter(() async => writeln('enter sub'));
      leave(() async => writeln('leave sub'));
      item('write hi', () => write('hi'));
    });
    group('checks', () {
      test('api url is set', () {
        expect(apiUrl.valid, isTrue);
      });
    });
  });
}
```

### The HTML page

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>test menu</title>
  <script defer src="main.dart.js"></script>
</head>
<body>
<div id="tekartik_test_menu_container"></div>
</body>
</html>
```

### Browser-only entry point with extra JavaScript

```dart
// web/interactive_tests.dart
import 'package:tekartik_test_menu_browser/test_menu_web.dart';

Future<void> main() async {
  await initTestMenuBrowser(jsFiles: ['my_lib.js']);
  menu('main', () {
    item('call a js global', () {
      jsTest('myGlobalFunction');
    });
    item('crash', () {
      throw StateError('crash');
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

### Same declaration, console entry point

```dart
// tool/menu.dart — dart run tool/menu.dart
// In a real project declareCommonMenu() lives in a shared library importing
// only package:tekartik_test_menu/test_menu.dart, and web/main.dart calls it
// through mainMenu() of test_menu_universal.dart.
import 'package:tekartik_test_menu_io/test_menu_io.dart';

void declareCommonMenu() {
  menu('main', () {
    item('write hola', () => write('Hola'));
    item('echo prompt', () async {
      writeln('RESULT prompt: ${await prompt()}');
    });
  });
}

void main(List<String> arguments) {
  initTestMenuConsole(arguments);
  declareCommonMenu();
}
```

### localStorage values in a browser-only menu

```dart
// web/vars_menu.dart
import 'package:tekartik_test_menu_browser/key_value_web.dart';
import 'package:tekartik_test_menu_browser/test_menu_web.dart';

var myVar = 'MYVAR'.kvFromLocalStorage(defaultValue: '12345');
var myOtherVar = 'MYOTHERVAR'.kvFromLocalStorage();

Future<void> main() async {
  await mainMenuWeb(() {
    keyValuesMenu('vars', [myVar, myOtherVar]);
    item('dump', () => [myVar, myOtherVar].dump());
    item('set myVar', () async {
      var kv = await myVar.promptToLocalStorage();
      write(kv);
    });
  });
}
```

### Testing the universal key values on vm and chrome

```dart
// test/key_value_universal_test.dart — dart test -p vm,chrome
import 'package:tekartik_test_menu_browser/key_value_universal.dart';
import 'package:test/test.dart';

void main() {
  test('delete/set/get', () async {
    var kv = 'n1xqmEiN4xLJy6bQDGNk.myTestVar'.kvFromVar();
    await kv.delete();
    expect(kv.get(), isNull);
    await kv.set('test');
    expect(getVar(kv.key), 'test');
    await setVar(kv.key, 'test2');
    expect(kv.get(), 'test2');
    await deleteVar(kv.key);
    expect(getVar(kv.key), isNull);
  });
}
```

## Common mistakes

* Importing `test_menu_universal.dart` and `test_menu_web.dart` together, or
  passing `arguments` to the one-argument `mainMenu` of `test_menu_web.dart`.
* Forgetting to `await mainMenu(...)` / `mainMenuWeb(...)` /
  `initTestMenuBrowser()`: the declaration then runs before the presenter is
  installed.
* Opening the `.dart` file directly instead of serving the compiled page
  (`webdev serve`), or serving a page whose `<script>` does not point at the
  compiled `*.dart.js`.
* Being surprised that a reload re-runs the last item: that is the
  `window.location.hash` feature, clear the hash to get a plain menu.
* Using the `@Deprecated` `test_menu_mdl_browser*` / `*_compat` libraries.
* Putting an interactive menu under `test/`, where it never terminates.
