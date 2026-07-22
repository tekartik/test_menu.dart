library;

import 'package:meta/meta.dart';
import 'package:tekartik_test_menu/test.dart';

export 'package:matcher/matcher.dart';

export 'src/expect.dart' show expect, fail;
export 'test_menu.dart';

/// Declare a test item
///
/// can return a future
///
/// @param cmd command shortcut (instead of incremental number)
void test(
  String name,

  dynamic Function() body, {
  String? cmd,
  @doNotSubmit bool? solo,
}) {
  // ignore: invalid_use_of_do_not_submit_member
  item(name, body, cmd: cmd, solo: solo);
}

/// Declare a solo test item, all other tests will be skipped.
// deprecated for temp usage only
@doNotSubmit
// ignore: non_constant_identifier_names
void solo_test(String name, dynamic Function() body, {String? cmd}) {
  // ignore: invalid_use_of_do_not_submit_member
  item(name, body, cmd: cmd, solo: true);
}

/// Declare a test group
///
/// @param cmd command shortcut (instead of incremental number)
void group(
  String name,

  void Function() body, {
  String? cmd,
  @doNotSubmit bool? solo,
}) {
  // ignore: invalid_use_of_do_not_submit_member
  menu(name, body, group: true, solo: solo);
}

/// Declare a solo test group, all other tests will be skipped.
// deprecated for temp usage only
@doNotSubmit
// ignore: non_constant_identifier_names
void solo_group(String name, void Function() body, {String? cmd}) {
  // ignore: invalid_use_of_do_not_submit_member
  group(name, body, solo: true);
}
