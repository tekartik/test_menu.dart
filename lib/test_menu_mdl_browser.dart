library tekartik_test_menu_browser;

import 'dart:html';
import 'test_menu.dart';
import 'package:tekartik_mdl_js/mdl_js_loader.dart';
//import 'package:tekartik_mdl_js/mdl_js.dart';
import 'package:tekartik_mdl_js/mdl_list.dart';
import 'dart:async';

const String CONTAINER_ID = "tekartik_test_menu_container";

// can be extended
class TestMenuManagerBrowser extends TestMenuManager {
  TestMenu displayedMenu = null;
  Element container = null;

  TestMenuManagerBrowser() {
    String hash = window.location.hash;

    initCommands = TestMenuManager.initCommandsFromHash(hash);
    //_handleHash();
    /*
    window.onHashChange.listen((HashChangeEvent hashChangedEvent) {
      _handleHash();
    });
    _handleHash();
    */
  }

  /*
  _handleHash() {
    String hash = window.location.hash;

    String pageId = PageId.home;

    String pagePath = join(url.separator, pageId);

    List<String> parts;

  }
  */

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

      //StringBuffer sb = new StringBuffer();
      int popCount = activeDepth;
      for (TestMenu testMenu in testMenuManager.stackMenus) {
        int menuPopCount = popCount--;
        header.append(new AnchorElement(href: '#')
          ..text = ' > ${testMenu.name}'
          ..onClick.listen((_) {
            print('$menuPopCount / $activeDepth');
            if (menuPopCount <= activeDepth && menuPopCount > 0) {
              testMenuManager.pop(menuPopCount);
            }
          }));
      }
      //header.setInnerHtml(sb.toString());
      Element list = listCreate();

      Element liElement;

      if (activeDepth > 0) {
        liElement = listItemCreate()
          ..append(listItemPrimaryContentCreate()..appendText(" - exit"))
          ..onClick.listen((_) {
            testMenuManager.pop();
          });
        list.children.add(liElement);
      }

      for (int i = 0; i < menu.length; i++) {
        int index = i;
        TestItem item = menu[i];
        liElement = listItemCreate()
          ..append(listItemPrimaryContentCreate()..appendText("$i ${item}"))
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

Future initTestMenuBrowser() async {
  await Future.wait([loadMdlJs(), loadMdlCss(), loadMaterialIconsCss()]);
  _testMenuManagerBrowser = new TestMenuManagerBrowser();
}

TestMenuManagerBrowser _testMenuManagerBrowser;
