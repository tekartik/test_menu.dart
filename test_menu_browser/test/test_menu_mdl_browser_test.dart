@TestOn('browser')
library test_menu_browser.test_menu_mdl_browser_test;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:test/test.dart';

void main() {
  group('mdl', () {
    test('init', () async {
      await initTestMenuBrowser();
    });
  });
}
