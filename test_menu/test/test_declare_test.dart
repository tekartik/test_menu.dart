// ignore_for_file: implementation_imports
import 'package:dev_build/src/menu/dev_menu.dart';
import 'package:dev_build/src/menu/menu.dart' show menuNewDeclarer;
import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu/src/key_value_menu.dart';
import 'package:tekartik_test_menu/test.dart' as tm;
import 'package:test/test.dart';

/// The menu of the [MenuMenuItem] named [name] in [menu].
DevMenu subMenu(DevMenu menu, String name) =>
    (menu.items.firstWhere((item) => item.name == name) as MenuMenuItem).menu;

List<String> itemNames(DevMenu menu) => [
  for (var item in menu.items) item.name,
];

void main() {
  group('declare', () {
    test('group cmd', () {
      var root = menuNewDeclarer().devMenu;
      tm.group('g', () {
        tm.test('t', () {}, cmd: 'tt');
      }, cmd: 'gg');
      expect(root.byCmd('gg')?.name, 'g');
      expect(subMenu(root, 'g').byCmd('tt')?.name, 't');
    });
    test('solo_group cmd', () {
      var root = menuNewDeclarer().devMenu;
      // ignore: invalid_use_of_do_not_submit_member
      tm.solo_group('g', () {}, cmd: 'gg');
      expect(root.byCmd('gg')?.name, 'g');
    });
    test('key values menu', () {
      var root = menuNewDeclarer().devMenu;
      var kvs = [KeyValue('K1', 'v1'), KeyValue('K2', null)];
      keyValuesMenuImpl(
        'vars',
        kvs,
        promptKv: (kv) async => kv,
        deleteKv: (kv) async {},
      );
      var vars = subMenu(root, 'vars');
      expect(itemNames(vars), [
        'dump',
        'all',
        'prompt invalids',
        'update K1',
        'update K2',
        'clear one by one',
      ]);
      expect(itemNames(subMenu(vars, 'clear one by one')), [
        'delete K1',
        'delete K2',
      ]);
      // Nothing added to the root menu.
      expect(itemNames(root), ['vars']);
    });
  });
}
