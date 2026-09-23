@TestOn('browser')
library;

import 'package:tekartik_prefs_browser/prefs_light.dart';
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

Future<void> _untilAsync(Future<bool> Function() condition) async {
  for (var i = 0; i < 100 && !await condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(await condition(), isTrue);
}

HTMLElement _element(String selector) =>
    document.querySelector(selector)! as HTMLElement;

void _setInput(HTMLInputElement input, String value) {
  input.value = value;
  input.dispatchEvent(Event('input'));
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
    expect(_texts('.tm-quick .tm-chip'), ['s shortcut', '0 write hi']);

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

  test('menu layout', () async {
    if (document.querySelector('.tm-root') == null) {
      await initTestMenuBrowser();
    }
    // What the presenter uses by default.
    final prefs = getPrefsLightBrowser(name: 'tekartik_test_menu');
    Future<Map<String, Object?>?> savedMenu() => prefs.getMap('menu');

    final frame = _element('.tm-window');
    final menu = _element('.tm-menu');
    final menuButton = _element('.tm-titlebar [aria-pressed]');
    expect(frame.hasAttribute('data-menu-hidden'), isFalse);
    expect(frame.hasAttribute('data-menu-limit'), isTrue);
    expect(menuButton.getAttribute('aria-label'), 'Hide menu');

    menuButton.click();
    expect(frame.hasAttribute('data-menu-hidden'), isTrue);
    expect(window.getComputedStyle(menu).display, 'none');
    expect(menuButton.getAttribute('aria-label'), 'Show menu');
    await _untilAsync(() async => (await savedMenu())?['hidden'] == true);

    menuButton.click();
    expect(frame.hasAttribute('data-menu-hidden'), isFalse);
    expect(window.getComputedStyle(menu).display, isNot('none'));
    await _untilAsync(() async => (await savedMenu())?['hidden'] == false);

    final settings = _element('.tm-settings');
    expect(settings.hasAttribute('hidden'), isTrue);
    _element('.tm-titlebar [aria-expanded]').click();
    expect(settings.hasAttribute('hidden'), isFalse);

    final inputs = document.querySelectorAll('.tm-settings .tm-num');
    final percent = inputs.item(0)! as HTMLInputElement;
    final minHeight = inputs.item(1)! as HTMLInputElement;
    final maxHeight = inputs.item(2)! as HTMLInputElement;
    expect(
      [percent.value, minHeight.value, maxHeight.value],
      ['40', '120', '480'],
    );

    _setInput(percent, '30');
    expect(frame.style.getPropertyValue('--tm-menu-percent'), '30%');
    await _untilAsync(() async => (await savedMenu())?['percent'] == 30);

    // Out of range, ignored and shown back once done.
    _setInput(percent, '3');
    expect(frame.style.getPropertyValue('--tm-menu-percent'), '30%');
    percent.dispatchEvent(Event('change'));
    expect(percent.value, '30');

    _setInput(minHeight, '50');
    _setInput(maxHeight, '50');
    expect(frame.style.getPropertyValue('--tm-menu-max'), '50px');
    // Only below the output (narrow screens).
    if (window.innerWidth < 900) {
      expect(window.getComputedStyle(menu).maxHeight, '50px');
    } else {
      expect(window.getComputedStyle(menu).maxHeight, 'none');
    }
    await _untilAsync(() async => (await savedMenu())?['max'] == 50);

    final limit =
        document
                .querySelectorAll('.tm-settings input[type="checkbox"]')
                .item(1)!
            as HTMLInputElement;
    limit.click();
    expect(frame.hasAttribute('data-menu-limit'), isFalse);
    expect(percent.disabled, isTrue);
    expect(window.getComputedStyle(menu).maxHeight, 'none');

    _element('.tm-settings-reset').click();
    expect(frame.hasAttribute('data-menu-limit'), isTrue);
    expect(
      [percent.value, minHeight.value, maxHeight.value],
      ['40', '120', '480'],
    );
    await _untilAsync(() async => await savedMenu() == null);
  });
}
