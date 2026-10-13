// ignore_for_file: deprecated_member_use

library;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:tekartik_browser_utils/location_info_utils.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart'; // ignore: implementation_imports
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart'; // ignore: implementation_imports
import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:tekartik_test_menu_browser/src/common_browser.dart';
import 'package:tekartik_test_menu_browser/src/import.dart';
import 'package:tekartik_test_menu_browser/src/menu_stack_names.dart';
import 'package:tekartik_test_menu_browser/test_menu_web.dart'
    show testMenuLoadJs;

export 'package:tekartik_test_menu/test_menu.dart';
export 'package:tekartik_test_menu_browser/src/common_browser.dart';

@Deprecated('Use testMenuBrowserContainerId')
// ignore: constant_identifier_names
const String CONTAINER_ID = testMenuBrowserContainerId;
const String testMenuBrowserContainerId = 'tekartik_test_menu_container';

void jsTest(String name) {
  context.callMethod(name);
}

// can be extended
class TestMenuManagerBrowser extends TestMenuPresenter
    with TestMenuPresenterMixin {
  TestMenu? displayedMenu;
  Element? container;

  Element? menuContainer;
  Element? output;
  InputElement? basicInput;

  var outBuffer = OutBuffer(100);

  void commonLog(Object message) {
    // ignore: avoid_print
    print('[w] $message');
  }

  @override
  void write(Object message) {
    writeln(message);
  }

  @override
  void writeln(Object message) {
    outBuffer.add('$message');
    if (debugTestMenuManager) {
      // ignore: avoid_print
      print('[bwsr writ] $message');
    }
    commonLog(message);
    output!.text = outBuffer.toString();
  }

  Completer<String>? promptCompleter;

  @override
  Future<String> prompt(Object? message) {
    write(message ?? 'Enter text');
    var completer = Completer<String>.sync();
    promptCompleter = completer;
    return completer.future;
  }

  TestMenuManagerBrowser() {
    if (locationInfo!.arguments.containsKey('debug')) {
      TestMenuManager.debug.on = true;
    }
  }

  void findContainer() {
    if (container == null) {
      container = document.getElementById(testMenuBrowserContainerId);
      if (container == null) {
        container = DivElement();
        document.body!.children.add(container!);
      }

      basicInput = InputElement();

      basicInput!.onChange.listen((_) {
        // devPrint('on change: ${basicInput.value}');
        if (promptCompleter != null) {
          promptCompleter!.complete(basicInput!.value);
          promptCompleter = null;
        }
      });

      menuContainer = DivElement();

      output = PreElement();

      container!.children.addAll([output!, menuContainer!, basicInput!]);
    }
  }

  // for href
  List<String> getMenuStackNames([TestItem? item]) => testMenuStackNames(item);

  @override
  Future preProcessItem(TestItem item) async {
    window.location.hash = '#${getMenuStackNames(item).join('_')}';
    // process after setting the hash to allow reload in case of crash in processing
    await super.preProcessItem(item);
  }

  void displayMenu(TestMenu menu) {
    findContainer();

    if (displayedMenu != menu) {
      Element header = HeadingElement.h3();
      final sb = StringBuffer();
      for (final runner in testMenuManager!.stackMenus) {
        sb.write(' > ${runner.menu.name}');
      }
      // ignore: unsafe_html
      header.setInnerHtml(sb.toString());
      Element list = UListElement();

      LIElement liElement;

      if (testMenuManager!.activeDepth > 0) {
        liElement = LIElement();

        liElement
          // ignore: unsafe_html
          ..setInnerHtml(' - exit')
          ..onClick.listen((_) {
            testMenuManager!.popMenu();
          });
        list.children.add(liElement);
      }

      for (var i = 0; i < menu.length; i++) {
        final index = i;
        final item = menu[i];
        liElement = LIElement();
        liElement
          // ignore: unsafe_html
          ..setInnerHtml('$i $item')
          ..onClick.listen((_) {
            // ignore: avoid_print
            print("running '$index $item'");
            testMenuManager!.runItem(item).then((_) {
              // ignore: avoid_print
              print("done '$index $item'");
            });
          });
        list.children.add(liElement);
        //print('$i ${item}');
      }

      displayedMenu = menu;
      menuContainer!.children
        ..clear()
        ..addAll([header, list]);
    }
  }

  @override
  void presentMenu(TestMenu menu) {
    displayMenu(menu);
  }
}

Future<void> initTestMenuBrowser({List<String>? jsFiles}) async {
  await testMenuLoadJs(jsFiles);
  _testMenuManagerBrowser = TestMenuManagerBrowser();

  testMenuPresenter = _testMenuManagerBrowser!;

  initTestMenuManager();
  final hash = window.location.hash;
  testMenuManager!.initCommands = TestMenuManager.initCommandsFromHash(hash);
}

TestMenuManagerBrowser? _testMenuManagerBrowser;

/// Main menu declaration
Future<void> mainMenu(void Function() declare) async {
  await initTestMenuBrowser();
  declare();
}
