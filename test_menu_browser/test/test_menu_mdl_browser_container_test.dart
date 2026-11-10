// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('legacy mdl entry point uses an existing container', () async {
    var container = web.document.createElement('div')
      ..id = testMenuBrowserContainerId;
    web.document.body!.appendChild(container);
    await initTestMenuBrowser();
    expect(
      web.document.querySelectorAll('#$testMenuBrowserContainerId').length,
      1,
    );
    expect(container.classList.contains('tm-root'), isTrue);
  });
}
