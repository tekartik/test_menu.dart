import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:test/test.dart';

void main() {
  group('src_test_menu', () {
    test('function', () {
      bool ran = false;
      TestItem item = TestItem.fn("test", () {
        ran = true;
      });
      expect(item.name, "test");
      expect(ran, false);
      item.run();
      expect(ran, true);
    });

    test('enter', () {
      bool ran = false;
      MenuEnter enter = MenuEnter(() {
        ran = true;
      });
      expect(ran, false);
      enter.run();
      expect(ran, true);
    });

    test('leave', () {
      bool ran = false;
      MenuLeave leave = MenuLeave(() {
        ran = true;
      });
      expect(ran, false);
      leave.run();
      expect(ran, true);
    });

    test('menu', () {
      TestMenu menu = TestMenu("menu");
      TestItem item = TestItem.menu(menu);
      expect(item.name, "menu");
    });
  });

  group('test menu', () {
    test('list', () {
      TestMenu menu = TestMenu("menu");
      expect(menu.name, "menu");
      TestItem item = TestItem.fn("test", () => null);
      menu.addItem(item);
      expect(menu[0], item);
    });
  });
}
