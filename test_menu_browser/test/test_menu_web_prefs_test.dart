@TestOn('browser')
library;

import 'package:tekartik_prefs_browser/prefs_light.dart';
import 'package:tekartik_test_menu_browser/test_menu_web.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

void main() {
  test('saved prefs', () async {
    final prefs = PrefsMemory();
    await prefs.setString('theme', 'light');
    await prefs.setMap('menu', {
      'hidden': true,
      'limit': false,
      'percent': 50,
      'min': 20,
      // Out of range, default used
      'max': -1,
    });
    await initTestMenuBrowser(prefs: prefs);

    final root = document.querySelector('.tm-root')!;
    final frame = document.querySelector('.tm-window')! as HTMLElement;
    for (var i = 0; i < 100 && !frame.hasAttribute('data-menu-hidden'); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(frame.hasAttribute('data-menu-hidden'), isTrue);
    expect(frame.hasAttribute('data-menu-limit'), isFalse);
    expect(frame.style.getPropertyValue('--tm-menu-percent'), '50%');
    expect(frame.style.getPropertyValue('--tm-menu-min'), '20px');
    expect(frame.style.getPropertyValue('--tm-menu-max'), '480px');
    expect(root.getAttribute('data-theme'), 'light');
    expect(
      window.getComputedStyle(document.querySelector('.tm-menu')!).display,
      'none',
    );

    // Theme toggle saved
    (document.querySelector('.tm-titlebar .tm-icon-btn:last-child')!
            as HTMLElement)
        .click();
    expect(root.getAttribute('data-theme'), 'dark');
    expect(await prefs.getString('theme'), 'dark');
  });
}
