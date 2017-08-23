import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:test/test.dart';

main() {
  group('test item', () {
    test('function', () {
      bool ran = false;
      TestItem item = new TestItem.fn("test", () {
        ran = true;
      });
      expect(item.name, "test");
      expect(ran, false);
      item.run();
      expect(ran, true);
    });

    test('enter', () {
      bool ran = false;
      MenuEnter enter = new MenuEnter(() {
        ran = true;
      });
      expect(ran, false);
      enter.run();
      expect(ran, true);
    });

    test('leave', () {
      bool ran = false;
      MenuLeave leave = new MenuLeave(() {
        ran = true;
      });
      expect(ran, false);
      leave.run();
      expect(ran, true);
    });

    test('menu', () {
      TestMenu menu = new TestMenu("menu");
      TestItem item = new TestItem.menu(menu);
      expect(item.name, "menu");
    });
  });

  group('test menu', () {
    test('list', () {
      TestMenu menu = new TestMenu("menu");
      expect(menu.name, "menu");
      TestItem item = new TestItem.fn("test", () => null);
      menu.addItem(item);
      expect(menu[0], item);
    });
  });
}
