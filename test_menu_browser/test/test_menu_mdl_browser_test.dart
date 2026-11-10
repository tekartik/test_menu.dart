// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('legacy mdl entry point runs the default web menu', () async {
    var declared = false;
    await mainMenuBrowser(() {
      declared = true;
    });
    expect(declared, isTrue);
    expect(menuPresenter, isA<TestMenuManagerBrowser>());
    expect(web.document.querySelector('.tm-app'), isNotNull);
    expect(web.document.getElementById(testMenuBrowserContainerId), isNotNull);
  });
}
