library tekartik_test_menu_browser;

import 'dart:html';
import 'dart:js';

// ignore_for_file: implementation_imports

import 'package:tekartik_browser_utils/location_info_utils.dart';
import 'package:tekartik_common_utils/out_buffer.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_runner.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

import 'src/common_browser.dart';

export 'package:tekartik_test_menu/test_menu.dart';

export 'src/common_browser.dart';

@deprecated
const String CONTAINER_ID = "tekartik_test_menu_container";
const String testMenuBrowserContainerId = "tekartik_test_menu_container";

void jsTest(String name) {
  context.callMethod(name);
}

// can be extended
class TestMenuManagerBrowser extends TestMenuPresenter
    with TestMenuPresenterMixin {
  TestMenu displayedMenu;
  Element container;

  Element menuContainer;
  Element output;
  InputElement basicInput;

  var outBuffer = OutBuffer(100);

  @override
  void write(Object message) {
    outBuffer.add("$message");
    if (debugTestMenuManager) {
      print("[bwsr writ] $message");
    }
    //print("writing $text");
    output.text = outBuffer.toString();
  }

  Completer<String> promptCompleter;

  @override
  Future<String> prompt(Object message) {
    write(message ?? "Enter text");
    var completer = Completer<String>.sync();
    promptCompleter = completer;
    return completer.future;
  }

  TestMenuManagerBrowser() {
    if (locationInfo.arguments.containsKey("debug")) {
      // ignore: deprecated_member_use
      TestMenuManager.debug.on = true;
    }
  }

  void findContainer() {
    if (container == null) {
      container = document.getElementById(testMenuBrowserContainerId);
      if (container == null) {
        container = DivElement();
        document.body.children.add(container);
      }

      basicInput = InputElement();

      basicInput.onChange.listen((_) {
        // devPrint("on change: ${basicInput.value}");
        if (promptCompleter != null) {
          promptCompleter.complete(basicInput.value);
          promptCompleter = null;
        }
      });

      menuContainer = DivElement();

      output = PreElement();

      container.children.addAll([output, menuContainer, basicInput]);
    }
  }

  // for href
  List<String> getMenuStackNames([TestItem item]) {
    List<String> list = [];

    TestMenu lastMenu;
    //devPrint(testMenuManager.stackMenus);
    for (int i = testMenuManager.stackMenus.length - 1; i >= 0; i--) {
      TestMenu menu = testMenuManager.stackMenus[i].menu;

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
      Element header = HeadingElement.h3();
      StringBuffer sb = StringBuffer();
      for (TestMenuRunner runner in testMenuManager.stackMenus) {
        sb.write(' > ${runner.menu.name}');
      }
      header.setInnerHtml(sb.toString());
      Element list = UListElement();

      LIElement liElement;

      if (testMenuManager.activeDepth > 0) {
        liElement = LIElement();

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
        liElement = LIElement();
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
  void presentMenu(TestMenu menu) {
    displayMenu(menu);
  }
}

void initTestMenuBrowser({List<String> jsFiles}) {
  testMenuLoadJs(jsFiles);
  _testMenuManagerBrowser = TestMenuManagerBrowser();

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
