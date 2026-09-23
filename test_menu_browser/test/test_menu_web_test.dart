@TestOn('browser')
library;

import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:tekartik_test_menu_browser/test_menu_web.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

List<String> _texts(String selector) {
  final elements = document.querySelectorAll(selector);
  return [
    for (var i = 0; i < elements.length; i++) elements.item(i)!.textContent!,
  ];
}

String? _status() => document.querySelector('.tm-status')!.textContent;

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(condition(), isTrue);
}

void main() {
  test('web presenter', () async {
    await initTestMenuBrowser();
    var presenter = menuPresenter as TestMenuManagerBrowser;
    menu('main', () {
      item('write hi', () => write('hi'));
      item('ask', () async {
        write('got ${await prompt('Name?')}');
      });
      item('shortcut', () => write('short'), cmd: 's');
    });
    await testMenuRun();

    expect(document.querySelector('.tm-root'), isNotNull);
    expect(_texts('.tm-item-name'), ['main']);
    expect(_status(), 'READY');

    await presenter.processLine('0');
    expect(_texts('.tm-menu-title'), ['>_root_>main']);
    expect(_texts('.tm-item-name'), ['exit', 'write hi', 'ask', 'shortcut']);

    await presenter.processLine('0');
    await presenter.processLine('s');
    expect(_texts('.tm-log .tm-line').sublist(0, 4), [
      'main › 0 write hi',
      'hi',
      'main › s shortcut',
      'short',
    ]);
    expect(_texts('.tm-chip'), ['s shortcut', '0 write hi']);

    // A pending prompt is answered by the next line.
    var askFuture = presenter.processLine('1');
    await _until(() => presenter.promptCompleter != null);
    expect(_status(), 'INPUT');
    await presenter.processLine('Alex');
    await askFuture;
    expect(_status(), 'READY');
    expect(_texts('.tm-prompt-answer'), ['Alex']);
    expect(_texts('.tm-log .tm-line').last, 'got Alex');

    await presenter.processLine('unknown');
    expect(_texts('.tm-line-error').last, contains('Unknown command'));

    await presenter.processLine('-');
    expect(_texts('.tm-menu-title'), ['>_root_']);

    presenter.clearOutput();
    expect(_texts('.tm-log .tm-line'), isEmpty);
  });
}
