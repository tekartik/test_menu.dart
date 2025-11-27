import 'package:tekartik_test_menu_browser/key_value_universal.dart';

import 'package:test/test.dart';

Future<void> main() async {
  test('vars test', () async {
    var key = 'eAEVYA0YTid8HNjBbdMbBrowser';
    await deleteVar(key);
    expect(getVar(key), isNull);

    await setVar(key, 'value1');
    expect(getVar(key), 'value1');

    await setVar(key, 'value2');
    expect(getVar(key), 'value2');

    await deleteVar(key);
    expect(getVar(key), isNull);
  });
}
