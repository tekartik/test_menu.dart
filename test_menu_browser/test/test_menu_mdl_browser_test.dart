// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:test/test.dart';

void main() {
  group('mdl', () {
    test('init', () async {
      await initTestMenuBrowser();
    });
  });
}
