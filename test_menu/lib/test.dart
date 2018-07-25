import 'package:tekartik_test_menu/test_menu.dart';
export 'src/expect.dart' show expect, fail;
export 'package:matcher/matcher.dart';
export 'test_menu.dart';

///
/// Declare a test item
///
/// can return a future
///
/// @param cmd command shortcut (instead of incremental number)
void test(String name, body(), {String cmd}) {
  item(name, body, cmd: cmd, test: true);
}

///
/// Declare a test item
///
/// can return a future
///
/// @param cmd command shortcut (instead of incremental number)
void solo_test(String name, body(), {String cmd}) {
  item(name, body, cmd: cmd, test: true, solo: true);
}

void group(String name, void body(), {String cmd, bool solo}) {
  menu(name, body, group: true, solo: solo);
}

void solo_group(String name, void body(), {String cmd}) {
  group(name, body, solo: true);
}
