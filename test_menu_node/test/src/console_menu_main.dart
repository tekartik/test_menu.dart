import 'package:tekartik_test_menu_node/test_menu_console.dart';

/// Menu run by test_menu_console_test.dart.
void main(List<String> arguments) {
  mainMenuConsole(arguments, () {
    item('hi', () => write('hi'));
    menu('sub', () {
      command((line) => throw StateError('command failed: $line'));
      item('fail', () => throw StateError('item failed'));
    });
  });
}
