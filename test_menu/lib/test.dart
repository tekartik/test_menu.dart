import 'package:tekartik_test_menu/test_menu.dart';

export 'package:matcher/matcher.dart';

export 'src/expect.dart' show expect, fail;
export 'test_menu.dart';

///
/// Declare a test item
///
/// can return a future
///
/// @param cmd command shortcut (instead of incremental number)
void test(String name, dynamic Function() body,
    {String? cmd, @Deprecated('Dev only') bool? solo}) {
  // ignore: deprecated_member_use_from_same_package
  item(name, body, cmd: cmd, test: true, solo: solo);
}

// deprecated for temp usage only
@Deprecated('Dev only')
// ignore: non_constant_identifier_names
void solo_test(String name, dynamic Function() body, {String? cmd}) {
  item(name, body, cmd: cmd, test: true, solo: true);
}

///
/// Declare a test group
///
/// @param cmd command shortcut (instead of incremental number)
void group(String name, void Function() body, {String? cmd, bool? solo}) {
  // ignore: deprecated_member_use_from_same_package
  menu(name, body, group: true, solo: solo);
}

// deprecated for temp usage only
@Deprecated('Dev only')
// ignore: non_constant_identifier_names
void solo_group(String name, void Function() body, {String? cmd}) {
  group(name, body, solo: true);
}
