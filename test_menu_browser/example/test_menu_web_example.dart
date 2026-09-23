/// Web test menu example.
///
/// Serve with `dart run tool/example_serve.dart` (or
/// `webdev serve example:8060`) and open
/// http://localhost:8060/test_menu_web_example.html
///
/// Click an item or type its number in the command line (`-` to go back,
/// `?` for help, arrow up/down for the history). Reloading the page runs the
/// last item again.
library;

import 'package:tekartik_test_menu_browser/key_value_web.dart';
import 'package:tekartik_test_menu_browser/test_menu_web.dart';

import 'common_test_menu.dart';

var apiUrl = 'TEST_MENU_EXAMPLE_API_URL'.kvFromLocalStorage(
  defaultValue: 'http://localhost:8080',
);
var apiKey = 'TEST_MENU_EXAMPLE_API_KEY'.kvFromLocalStorage();

Future<void> main() async {
  await initTestMenuBrowser(jsFiles: ['test_menu_web_example.js']);

  // Shared with the console (example/io_test_menu.dart)
  commonTestMenu();

  menu('web', () {
    item('say hello (shortcut h)', () {
      write('Hello from the web test menu');
    }, cmd: 'h');
    item('long task', () async {
      for (var i = 1; i <= 3; i++) {
        await sleep(1000);
        write('step $i/3');
      }
      write('long task done');
    });
    item('async crash', () async {
      await sleep(200);
      throw StateError('async crash');
    });
    item('ask name', () async {
      var name = await prompt('Your name?');
      write('Hello ${name.isEmpty ? 'stranger' : name}');
    });
    item('js console.log', () {
      jsTest('testMenuExampleLog');
      write('Look at the browser console');
    });
    item('dynamic menu', () async {
      await showMenu(() {
        item('write dynamic', () => write('dynamic item'));
        item('close', () => popMenu());
      });
      write('dynamic menu closed');
    });
    keyValuesMenu('vars', [apiUrl, apiKey]);
    menu('calc', () {
      enter(() {
        write('Type an operation such as 6 * 7');
      });
      // Any line that is not an item number or shortcut ends up here.
      command((line) {
        var match = RegExp(
          r'^\s*(-?[\d.]+)\s*([-+*/])\s*(-?[\d.]+)\s*$',
        ).firstMatch(line);
        if (match == null) {
          write('Not an operation: $line');
          return;
        }
        var a = num.parse(match.group(1)!);
        var b = num.parse(match.group(3)!);
        var result = switch (match.group(2)) {
          '+' => a + b,
          '-' => a - b,
          '*' => a * b,
          _ => a / b,
        };
        write('$line = $result');
      });
      item('help', () {
        write('<number> <+|-|*|/> <number>, for example 6 * 7');
      });
    });
  });
}
