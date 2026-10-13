// ignore_for_file: deprecated_member_use_from_same_package

@TestOn('browser')
library;

import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('mdl existing container', () async {
    var container = web.document.createElement('div')
      ..id = 'tekartik_test_menu_container';
    var output = web.document.createElement('pre')..id = 'output';
    container.appendChild(output);
    web.document.body!.appendChild(container);
    await initTestMenuBrowser();
    // The input is created, prompting does not throw.
    prompt('value').ignore();
    expect(web.document.querySelectorAll('#output').length, 1);
    expect(web.document.querySelector('#input'), isNotNull);
  });
}
