@TestOn('browser')
library;

// ignore_for_file: implementation_imports
import 'package:dev_build/src/menu/dev_menu.dart';
import 'package:dev_build/src/menu/menu.dart' show menuNewDeclarer;
import 'package:tekartik_test_menu_browser/key_value_browser.dart';
import 'package:tekartik_test_menu_browser/key_value_universal.dart' as kvu;
import 'package:test/test.dart';

/// The menu of the [MenuMenuItem] named [name] in [menu].
DevMenu subMenu(DevMenu menu, String name) =>
    (menu.items.firstWhere((item) => item.name == name) as MenuMenuItem).menu;

List<String> itemNames(DevMenu menu) => [
  for (var item in menu.items) item.name,
];

void main() {
  test('keyValuesMenu clear one by one is a menu', () {
    var root = menuNewDeclarer().devMenu;
    keyValuesMenu('vars', [KeyValue('K1', 'v1'), KeyValue('K2', 'v2')]);
    var vars = subMenu(root, 'vars');
    expect(itemNames(subMenu(vars, 'clear one by one')), [
      'delete K1',
      'delete K2',
    ]);
    expect(itemNames(root), ['vars']);
  });
  test('fromLocalStorage reads the current value', () async {
    var key = 'n1xqmEiN4xLJy6bQDGNk.fromLocalStorage';
    var kv = key.kvFromVar();
    await kv.delete();
    expect(key.fromLocalStorage(defaultValue: 'd1'), 'd1');
    expect(key.fromVar(), isNull);
    await kv.set('stored');
    expect(key.fromLocalStorage(defaultValue: 'd1'), 'stored');
    expect(key.fromVar(), 'stored');
    await kv.delete();
    expect(key.fromLocalStorage(defaultValue: 'd2'), 'd2');
    expect(key.fromVar(), isNull);
  });
}
