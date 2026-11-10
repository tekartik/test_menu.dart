# tekartik_test_menu_node

Runs a [tekartik_test_menu](../test_menu) manual menu (`menu`, `item`,
`prompt`, `write`...) in a console on Node.js: the Dart entry point is
compiled to JavaScript (dart2js) and started with `node`. The same entry
point also runs on the Dart VM (`dart run`). For a plain Dart console menu,
[tekartik_test_menu_io](../test_menu_io) is the usual choice; in a browser,
[tekartik_test_menu_browser](../test_menu_browser).

## Getting started

Not on pub.dev, git dependencies:

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

The menu, `bin/menu.dart`:

```dart
import 'package:tekartik_test_menu_node/test_menu_console.dart';

void main(List<String> arguments) {
  mainMenuConsole(arguments, () {
    item('write hola', () => write('Hola'));
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text then [ENTER]')}');
    });
    menu('sub', () {
      item('write hi', () => write('hi'));
    });
  });
}
```

Compile it to `deploy/menu.js` and run it with node, `tool/run_menu.dart`
(`dart run tool/run_menu.dart`):

```dart
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_node_build/app_build.dart';

Future<void> main() async {
  var builder = NodeAppBuilder(options: NodeAppOptions(srcFile: 'menu.dart'));
  // stdin: the menu reads the keyboard.
  await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin));
}
```

Type an item number (`0`), `.` to leave a menu (and exit at the top), `?`
to list the menu again. Command line arguments are typed commands:
`node deploy/menu.js 0 .` runs item 0 and exits, `-h` prints the help, `-v`
traces each command. `dart run bin/menu.dart 0 .` does the same on the VM.

`node` must be installed. The compiled `deploy/menu.js` (with the node
preamble added by the builder) is what runs.

## Good to know

* `package:tekartik_test_menu_node/test_menu_console.dart` exports
  `package:tekartik_test_menu/test_menu.dart` plus `mainMenuConsole`; there is
  no `mainMenu`, `initTestMenuConsole` nor `usingSharedStdIn` (those are
  tekartik_test_menu_io's).
* Keep the declarations in a library importing only
  `package:tekartik_test_menu/test_menu.dart`: the same menu then runs with
  the io, browser and Flutter runners.
* An error thrown by an item is printed and the menu goes on.
* One prompt at a time: the next typed line answers the pending prompt.
* In an automated test, declare the menu and call `testMenuRun()`, without
  `mainMenuConsole`.
