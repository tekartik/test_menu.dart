library tekartik_test_menu_browser;

import 'dart:html';
import 'dart:js';

import 'package:tekartik_common_utils/out_buffer.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

import 'src/common_browser.dart';

export 'src/common_browser.dart';
export 'test_menu.dart';

const String CONTAINER_ID = "tekartik_test_menu_container";

js_test(String name) {
  context.callMethod(name);
}

// can be extended
class TestMenuManagerBrowser extends TestMenuPresenter
    with TestMenuPresenterMixin {
  TestMenu displayedMenu = null;
  Element container = null;

  Element menuContainer = null;
  Element output = null;
  InputElement basicInput;

  var outBuffer = new OutBuffer(100);

  void write(Object message) {
    outBuffer.add("$message");
    //print("writing $text");
    output.text = outBuffer.toString();
  }

  Completer<String> promptCompleter;

  @override
  Future<String> prompt(Object message) {
    write(message ?? "Enter text");
    var completer = new Completer<String>.sync();
    promptCompleter = completer;
    return completer.future;
  }

  TestMenuManagerBrowser() {}

  void findContainer() {
    if (container == null) {
      container = document.getElementById(CONTAINER_ID);
      if (container == null) {
        container = new DivElement();
        document.body.children.add(container);
      }

      basicInput = new InputElement();

      basicInput.onChange.listen((_) {
        // devPrint("on change: ${basicInput.value}");
        if (promptCompleter != null) {
          promptCompleter.complete(basicInput.value);
          promptCompleter = null;
        }
      });

      menuContainer = new DivElement();

      output = new PreElement();

      container.children.addAll([output, menuContainer, basicInput]);
    }
  }

  // for href
  List<String> getMenuStackNames([TestItem item]) {
    List<String> list = new List();

    TestMenu lastMenu = null;
    for (int i = testMenuManager.stackMenus.length - 1; i >= 0; i--) {
      TestMenu menu = testMenuManager.stackMenus[i];

      int index;

      if (lastMenu == null) {
        lastMenu = testMenuManager.activeMenu;
        if (item == null) {
          continue;
        }
        if (item is MenuTestItem) {
          // index = stackMenus[stackMenus.length - 2].indexOfItem(item);
          // nothing
          continue;
        } else {
          index = testMenuManager.activeMenu.indexOfItem(item);
        }
      } else {
        index = menu.indexOfMenu(lastMenu);
        lastMenu = menu;
      }

      list.insert(0, index.toString());
    }
    return list;
  }

  @override
  Future preProcessItem(TestItem item) async {
    window.location.hash = "#${getMenuStackNames(item).join('_')}";
    // process after setting the hash to allow reload in case of crash in processing
    super.preProcessItem(item);
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

      if (testMenuManager.activeDepth > 0) {
        liElement = new LIElement();

        liElement
          ..setInnerHtml(' - exit')
          ..onClick.listen((_) {
            testMenuManager.popMenu();
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
            testMenuManager.runItem(item);
          });
        list.children.add(liElement);
        //print('$i ${item}');
      }

      displayedMenu = menu;
      menuContainer.children
        ..clear()
        ..addAll([header, list]);
    }
  }

  @override
  presentMenu(TestMenu menu) {
    displayMenu(menu);
    processMenu(menu);
  }
}

void initTestMenuBrowser({List<String> jsFiles}) {
  testMenuLoadJs(jsFiles);
  _testMenuManagerBrowser = new TestMenuManagerBrowser();

  testMenuPresenter = _testMenuManagerBrowser;

  initTestMenuManager();
  String hash = window.location.hash;
  testMenuManager.initCommands = TestMenuManager.initCommandsFromHash(hash);
}

Future testMenuLoadJs(List<String> jsFiles) async {
  if (jsFiles != null) {
    for (String jsFile in jsFiles) {
      await loadJavascriptScript(jsFile);
    }
  }
}

TestMenuManagerBrowser _testMenuManagerBrowser;
