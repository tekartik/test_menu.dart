library test_menu_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_test_menu/test_menu.dart';

void main() {
  group('test_menu', () {
    //TestMenuManager.debug.on
    test('solo', () async {
      var ran = false;

      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      solo_item('test', () {
        ran = true;
      });

      await testMenuRun();
      expect(ran, isTrue);
    });

    test('enter', () async {
      var ran = false;

      enter(() {
        ran = true;
      });

      await testMenuRun();
      expect(ran, isTrue);
    });
  });

  /*
      TestItem item = new TestItem.fn('test', () {
        ran = true;
      });
      expect(item.name, 'test');
      expect(ran, false);
      item.run();
      expect(ran, true);
    });

    test('menu', () {
      TestMenu menu = new TestMenu('menu');
      TestItem item = new TestItem.menu(menu);
      expect(item.name, 'menu');
    });
  });

  group('test menu', () {
    test('list', () {
      TestMenu menu = new TestMenu('menu');
      expect(menu.name, 'menu');
      TestItem item = new TestItem.fn('test', () => null);
      menu.addItem(item);
      expect(menu[0], item);
    });
  });
  */
}
