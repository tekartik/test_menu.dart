library test_menu_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_test_menu/test_menu.dart' as _;
import 'package:tekartik_test_menu/test.dart' as _;

main() {
  group('test', () {
    //TestMenuManager.debug.on
    test('auto_run', () async {
      bool ran = false;

      _.group("group", () {

        // ignore: deprecated_member_use
        _.solo_test("test", () {
          ran = true;
        });
      });

      await _.testMenuRun();
      expect(ran, isTrue);
    });
  });

  group('expect', () {
    //TestMenuManager.debug.on
    test('fail', () async {
      bool ran = false;

      _.group("group", () {
        // ignore: deprecated_member_use
        _.solo_test("test", () {
          ran = true;
          //_.expect(true, isFalse);
        });
      });

      await _.testMenuRun();
      expect(ran, isTrue);
    });

    test('success', () async {
      bool ran = false;

      _.group("group", () {
        // ignore: deprecated_member_use
        _.solo_test("test", () {
          _.expect(true, isTrue);
          ran = true;
        });
      });

      await _.testMenuRun();
      expect(ran, isTrue);
    });
  });

  /*
      TestItem item = new TestItem.fn("test", () {
        ran = true;
      });
      expect(item.name, "test");
      expect(ran, false);
      item.run();
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
  */
}
