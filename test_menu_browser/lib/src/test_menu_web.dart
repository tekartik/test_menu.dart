library;

import 'dart:js_interop' hide JSAnyOperatorExtension;
import 'dart:js_interop_unsafe';

//import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_browser_utils/css_utils.dart';
import 'package:tekartik_browser_utils/location_info_utils.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart'; // ignore: implementation_imports
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart'; // ignore: implementation_imports
import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:tekartik_test_menu_browser/src/common_browser.dart';
import 'package:tekartik_test_menu_browser/src/import.dart';
import 'package:web/web.dart';

export 'package:tekartik_test_menu/test_menu.dart';
export 'package:tekartik_test_menu_browser/src/common_browser.dart';

void _log(Object message) {
  print('/tmw $message');
}

// var debugTestMenuWeb = devWarning(true);
const debugTestMenuWeb = false;
@Deprecated('Use testMenuBrowserContainerId')
// ignore: constant_identifier_names
const String CONTAINER_ID = testMenuBrowserContainerId;
const String testMenuBrowserContainerId = 'tekartik_test_menu_container';

void jsTest(String name) {
  globalContext.callMethod(name.toJS);
}

// can be extended
class TestMenuManagerBrowser extends TestMenuPresenter
    with TestMenuPresenterMixin {
  TestMenu? displayedMenu;
  Element? container;

  Element? menuContainer;
  Element? output;
  HTMLInputElement? basicInput;

  var outBuffer = OutBuffer(100);

  void commonLog(Object message) {
    print('[w] $message');
  }

  @override
  void write(Object message) {
    outBuffer.add('$message');
    if (debugTestMenuManager) {
      _log('[bwsr writ] $message');
    }
    commonLog(message);
    output!.text = outBuffer.toString();
  }

  Completer<String>? promptCompleter;

  @override
  Future<String> prompt(Object? message) async {
    write('[PROMPT]: ${message ?? 'Enter text'}');
    var completer = Completer<String>.sync();
    promptCompleter = completer;
    if (debugTestMenuWeb) {
      _log('promptCompleter ${promptCompleter.hashCode}');
    }
    var result = await completer.future;
    if (debugTestMenuWeb) {
      _log('Prompt result $result');
    }
    return result;
  }

  TestMenuManagerBrowser() {
    if (locationInfo!.arguments.containsKey('debug')) {
      // ignore: deprecated_member_use
      TestMenuManager.debug.on = true;
    }
  }

  void findContainer() {
    if (container == null) {
      container = document.getElementById(testMenuBrowserContainerId);
      if (container == null) {
        container = HTMLDivElement();
        document.body!.appendChild(container!);
        print('body: ${document.body!.innerHTML}');
      }

      basicInput = HTMLInputElement();

      basicInput!.onChange.listen((_) {
        var promptCompleter = this.promptCompleter;
        var value = basicInput!.value;
        if (debugTestMenuWeb) {
          _log(
              'on change: $value ${promptCompleter?.hashCode} ${promptCompleter?.isCompleted}');
        }
        if (promptCompleter != null) {
          _log('set null completer');
          this.promptCompleter = null;
          if (!promptCompleter.isCompleted) {
            promptCompleter.complete(value);
          }
        }
      });

      menuContainer = HTMLDivElement();

      output = HTMLPreElement.pre();

      container!
        ..appendChild(output!)
        ..appendChild(menuContainer!)
        ..appendChild(basicInput!);
    }
  }

  // for href
  List<String> getMenuStackNames([TestItem? item]) {
    final list = <String>[];

    TestMenu? lastMenu;
    //devPrint(testMenuManager.stackMenus);
    for (var i = testMenuManager!.stackMenus.length - 1; i >= 0; i--) {
      final menu = testMenuManager!.stackMenus[i].menu;

      int index;

      if (lastMenu == null) {
        lastMenu = testMenuManager!.activeMenu;
        if (item == null) {
          continue;
        }
        // ignore: dead_code
        if (false) {
          // item is DevTestItem) {
          // index = stackMenus[stackMenus.length - 2].indexOfItem(item);
          // nothing
          continue;
        } else {
          index = testMenuManager!.activeMenu!.indexOfItem(item);
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
    window.location.hash = '#${getMenuStackNames(item).join('_')}';
    // process after setting the hash to allow reload in case of crash in processing
    await super.preProcessItem(item);
  }

  void displayMenu(TestMenu menu) {
    findContainer();

    if (displayedMenu != menu) {
      Element header = HTMLHeadingElement.h3();
      final sb = StringBuffer();
      for (final runner in testMenuManager!.stackMenus) {
        sb.write(' > ${runner.menu.name}');
      }
      header.textContent = sb.toString();
      Element list = HTMLUListElement();

      HTMLLIElement liElement;

      if (testMenuManager!.activeDepth > 0) {
        liElement = HTMLLIElement();

        liElement
          ..textContent = ' - exit'
          ..onClick.listen((_) {
            testMenuManager!.popMenu();
          });
        list.appendChild(liElement);
      }

      for (var i = 0; i < menu.length; i++) {
        final index = i;
        final item = menu[i];
        liElement = HTMLLIElement();
        liElement
          // ignore: unsafe_html
          ..textContent = ('$i $item')
          ..onClick.listen((_) {
            print("running '$index $item'");
            testMenuManager!.runItem(item).then((_) {
              print("done '$index $item'");
            });
          });
        list.appendChild(liElement);
        //print('$i ${item}');
      }

      var children = menuContainer!.children;
      displayedMenu = menu;
      for (var i = 0; i < children.length; i++) {
        children.item(i)!.remove();
      }

      menuContainer!
        ..appendChild(header)
        ..appendChild(list);
    }
  }

  @override
  void presentMenu(TestMenu menu) {
    displayMenu(menu);
  }
}

Future<void> initTestMenuBrowser({List<String>? jsFiles}) async {
  var futures = [
    testMenuLoadJs(jsFiles),
    () async {
      // print('Loading timesheet');
      try {
        await loadStylesheet(
            'packages/tekartik_test_menu_browser/css/test_menu_web.css');
        print('Loaded timesheet');
      } catch (e) {
        print('Error loading timesheet: $e');
      }
    }()
  ];
  await Future.wait(futures);
  _testMenuManagerBrowser = TestMenuManagerBrowser();

  testMenuPresenter = _testMenuManagerBrowser!;

  initTestMenuManager();
  final hash = window.location.hash;
  testMenuManager!.initCommands = TestMenuManager.initCommandsFromHash(hash);
}

Future testMenuLoadJs(List<String>? jsFiles) async {
  if (jsFiles != null) {
    for (final jsFile in jsFiles) {
      await loadJavascriptScript(jsFile);
    }
  }
}

TestMenuManagerBrowser? _testMenuManagerBrowser;

/// Compat
Future<void> mainMenu(void Function() declare) async {
  await mainMenuWeb(declare);
}

/// Main menu declaration
Future<void> mainMenuWeb(void Function() declare) async {
  await initTestMenuBrowser();
  declare();
}
