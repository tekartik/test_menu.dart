# tekartik_test_menu_io

The console runner of [tekartik_test_menu](../test_menu/README.md): a menu
declared with `menu`/`item` (or `group`/`test`) is printed as a numbered list
on stdout and the choices are read on stdin. It also persists prompted values
(urls, tokens) as `process_run` environment variables. Dart VM only (`dart
run`), not on pub.dev.

## Getting started

```yaml
dependencies:
  tekartik_test_menu_io:
    git:
      url: https://github.com/tekartik/test_menu.dart
      path: test_menu_io
```

```dart
// tool/menu.dart, run with: dart run tool/menu.dart
import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

/// MY_API_URL from the process_run env files (or the environment).
var apiUrl = 'MY_API_URL'.kvFromEnv(defaultValue: 'http://localhost:8080');

void main(List<String> arguments) {
  mainMenu(arguments, () {
    item('say hi', () => write('hi'), cmd: 'h');
    item('ask', () async {
      var name = await prompt('Your name');
      write('Hello $name');
    });
    menu('sub', () {
      item('api url', () => write(apiUrl));
    });
    // dump / prompt / update / delete the values (.local/ds_env.yaml)
    keyValuesMenu('vars', [apiUrl]);
  });
}
```

Type the number (or the `cmd`) of an item, `.` to go back (or exit), `?` to
show the menu again. The command line arguments are replayed as typed lines:
`dart run tool/menu.dart h .` runs `say hi` then exits.

## Libraries

* `test_menu_io.dart`: `mainMenu(arguments, declare)` plus everything of
  `tekartik_test_menu` (`menu`, `item`, `write`, `prompt`, `showMenu`,
  `group`/`test` through `package:tekartik_test_menu/test.dart`...).
* `key_value_io.dart`: `'NAME'.kvFromEnv()`, `kv.promptToEnv()`,
  `kv.setToEnv(value)`, `kv.deleteFromEnv()`, `keyValuesMenu(name, kvs)`, and
  `getEnvVar`/`setEnvVar`/`deleteEnvVar` (`user: true` for the user env file
  `~/.config/tekartik/process_run/env.yaml`, the local `.local/ds_env.yaml`
  of the current directory by default; the local value wins).

## Common pitfalls

* The values are written to process_run env files, not to the process
  environment of the shell: other `dart run` scripts and `ds` see them, a
  parent shell does not.
* Do not import `package:test/test.dart` next to
  `package:tekartik_test_menu/test.dart`: both declare `test` and `group`.
* For the web, node or Flutter use `tekartik_test_menu_browser`,
  `tekartik_test_menu_node` or `tekartik_test_menu_flutter` instead.

Examples: [example/demo.dart](example/demo.dart),
[example/kv_example.dart](example/kv_example.dart). Agent skill:
[skills/tekartik-test-menu-io-setup](skills/tekartik-test-menu-io-setup/SKILL.md).
