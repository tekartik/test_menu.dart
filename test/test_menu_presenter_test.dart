library test_menu_test;

import 'dart:async';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_test_menu/src/common_import.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:dev_test/test.dart';
import 'package:tekartik_test_menu/test_menu.dart';

class TestMenuPresenter1 extends Object
    with TestMenuPresenterMixin
    implements TestMenuPresenter {
  String text;

  TestMenuPresenter1() {
    // set as presenter
    testMenuPresenter = this;
  }
  TestMenu menu;
  @override
  presentMenu(TestMenu menu) {
    this.menu = menu;
  }

  @override
  Future<String> prompt(Object message) async {
    return null;
  }

  @override
  void write(Object message) {
    text = message.toString();
  }
}

main() {
  group('test_menu_presenter', () {
    test('test_menu', () async {
      var presenter = new TestMenuPresenter1();
      //menu('test', () {});
      await testMenuRun();
      write("some text");

      // presenter is still null
      expect(presenter.menu.name, null);
      expect(presenter.text, "some text");
      //expect(presenter.menu.name, "test");
      //expect(presenter.text, "some text");
    });

    test('enter_only', () async {
      bool ran = false;

      // We always need a presenter
      new NullTestMenuPresenter();
      enter(() {
        ran = true;
      });

      await testMenuRun();
      expect(ran, isTrue);
    });

    test('enter_then_item', () async {
      bool ran = false;
      bool ranEnter = false;

      // We always need a presenter
      new NullTestMenuPresenter();
      enter(() async {
        sleep(1);
        ranEnter = true;
      });
      item("test", () {
        expect(ranEnter, isTrue);
        ran = true;
      });

      testMenuManager.initCommands = ["0"];
      await testMenuRun();
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
