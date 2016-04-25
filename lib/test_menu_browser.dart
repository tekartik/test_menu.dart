library tekartik_test_menu_browser;

import 'dart:html';
import 'test_menu.dart';

const String CONTAINER_ID = "tekartik_test_menu_container";

// can be extended
class TestMenuManagerBrowser extends TestMenuManager {
  TestMenu displayedMenu = null;
  Element container = null;

  TestMenuManagerBrowser() {
    String hash = window.location.hash;

    initCommands = TestMenuManager.initCommandsFromHash(hash);
  }

  void findContainer() {
    if (container == null) {
      container = document.getElementById(CONTAINER_ID);
      if (container == null) {
        container = new DivElement();
        document.body.children.add(container);
      }
    }
  }

  void onProcessItem(TestItem item) {
    super.onProcessItem(item);

    List<String> list = new List();

    TestMenu lastMenu = null;
    for (int i = stackMenus.length - 1; i >= 0; i--) {
      TestMenu menu = stackMenus[i];

      int index;

      if (lastMenu == null) {
        lastMenu = activeMenu;
        if (item is MenuTestItem) {
          // index = stackMenus[stackMenus.length - 2].indexOfItem(item);
          // nothing
          continue;
        } else {
          index = activeMenu.indexOfItem(item);
        }
      } else {
        index = menu.indexOfMenu(lastMenu);
        lastMenu = menu;
      }

      list.insert(0, index.toString());
    }

    window.location.hash = "#${list.join('_')}";
  }

  void displayMenu(TestMenu menu) {
    findContainer();

    if (displayedMenu != menu) {
      Element header = new HeadingElement.h3();
      StringBuffer sb = new StringBuffer();
      for (TestMenu testMenu in testMenuManager.stackMenus) {
        sb.write(' > ${testMenu.name}');
      }
      header.setInnerHtml(sb.toString());
      Element list = new UListElement();

      LIElement liElement;

      if (activeDepth > 0) {
        liElement = new LIElement();

        liElement
          ..setInnerHtml(' - exit')
          ..onClick.listen((_) {
            testMenuManager.pop();
          });
        list.children.add(liElement);
      }

      for (int i = 0; i < menu.length; i++) {
        int index = i;
        TestItem item = menu[i];
        liElement = new LIElement();
        liElement
          ..setInnerHtml('$i ${item}')
          ..onClick.listen((_) {
            print("running '$index ${item}'");
            runItem(item);
          });
        list.children.add(liElement);
        print('$i ${item}');
      }

      displayedMenu = menu;
      container.children
        ..clear()
        ..addAll([header, list]);
    }
  }

  void showMenu(TestMenu menu) {
    displayMenu(menu);
    onProcessMenu(menu);
  }
}

void initTestMenuBrowser() {
  _testMenuManagerBrowser = new TestMenuManagerBrowser();
}

TestMenuManagerBrowser _testMenuManagerBrowser;
