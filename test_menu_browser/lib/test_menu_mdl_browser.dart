library;

import 'dart:html';

import 'package:tekartik_browser_utils/css_utils.dart';
import 'package:tekartik_mdl_js/mdl_button.dart';
import 'package:tekartik_mdl_js/mdl_classes.dart';
import 'package:tekartik_mdl_js/mdl_js_loader.dart';
import 'package:tekartik_mdl_js/mdl_list.dart';
import 'package:tekartik_mdl_js/mdl_textfield.dart';
import 'package:tekartik_platform_browser/context_browser.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:tekartik_test_menu_browser/src/import.dart';

import 'src/common_browser.dart';
import 'test_menu_browser.dart' as common_browser;
import 'test_menu_web.dart' as browser;

export 'package:tekartik_test_menu/test_menu.dart';

export 'src/common_browser.dart';
export 'test_menu_browser.dart' show jsTest;

// ignore_for_file: implementation_imports
// ignore_for_file: constant_identifier_names

//import 'package:tekartik_mdl_js/mdl_js.dart';

// 2019-01 deprecated
@Deprecated('Use testMenuBrowserContainerId')
const String CONTAINER_ID = testMenuBrowserContainerId;
@Deprecated('Use testMenuBrowserMenuId')
const String MENU_ID = testMenuBrowserMenuId;
@Deprecated('Use testMenuBrowserOutputId')
const String OUTPUT_ID = testMenuBrowserOutputId;
@Deprecated('Use testMenuBrowserInputId')
const String INPUT_ID = testMenuBrowserInputId;

const String testMenuBrowserContainerId = 'tekartik_test_menu_container';
const String testMenuBrowserMenuId = 'test_menu';
const String testMenuBrowserOutputId = 'output';
const String testMenuBrowserInputId = 'input';

// can be extended
class TestMenuManagerBrowser extends common_browser.TestMenuManagerBrowser {
  late TextField input;

  PlatformContext platformContext = platformContextBrowser;

  bool get isMobile => platformContext.browser!.isMobile;

  @override
  void write(Object message) {
    final text = '$message';
    if (debugTestMenuManager) {
      print('writing $text');
    }
    commonLog(message);
    outBuffer.add(text);
    output!.text = outBuffer.toString();
    autoScroll();
  }

  void initInputForMenu() {
    input.label = 'Your choice';
    input.value = '';

    if (!isMobile) {
      input.focus();
    }
  }

  @override
  void findContainer() {
    if (container == null) {
      container = document.getElementById(testMenuBrowserContainerId);
      if (container == null) {
        container = DivElement()..id = testMenuBrowserContainerId;
        document.body!.children.add(container!);

        menuContainer = DivElement()..id = testMenuBrowserMenuId;

        output = PreElement()..id = testMenuBrowserOutputId;

        var form = FormElement();
        form.setAttribute('action', '#');

        input = TextField(id: testMenuBrowserInputId, floatingLabel: true);
        form.append(input.element!);
        form.onSubmit.listen((Event e) {
          //print('on submit: ${input.value}');
          final value = input.value;
          input.value = null;
          e.preventDefault();
          if (promptCompleter != null) {
            promptCompleter!.complete(value);
            promptCompleter = null;

            initInputForMenu();
          } else {
            if (value == '-') {
              testMenuManager!.popMenu();
            } else {
              final index = int.tryParse(value!) ?? -1;
              //print('on submit: $value ${index}');
              if (index >= 0) {
                if (displayedMenu != null) {
                  testMenuManager!.runItem(displayedMenu![index]);
                }
              }
            }
          }
        });

        container!.children.addAll([output!, menuContainer!, form]);
      } else {
        output = container!.querySelector('#$testMenuBrowserOutputId');
        menuContainer = container!.querySelector('#$testMenuBrowserMenuId');
      }
    }
  }

  /*
  ???

  @override
  Future runItem(TestItem item) async {
    try {
      return await super.runItem(item);
    } catch (e, st) {
      write(e);
      write(st);
      write(e);
    }
  }
  */

  void autoScroll() {
    window.scrollTo(0, document.body!.scrollHeight);
  }

  //@override
  void init() {
    // devPrint('output: $output');
    findContainer();
  }

  void _updateMenuHash() {
    final menuNames = getMenuStackNames();
    window.location.hash = '#${menuNames.join('_')}';
  }

  @override
  void displayMenu(TestMenu menu) {
    findContainer();

    if (displayedMenu != menu) {
      //Element header = new HeadingElement.h4();
      Element header = DivElement();

      _updateMenuHash();

      //StringBuffer sb = new StringBuffer();
      var popCount = testMenuManager!.activeDepth;
      for (final runner in testMenuManager!.stackMenus) {
        final testMenu = runner.menu;
        final menuPopCount = popCount--;
        void clickOnMenu([_]) {
          //devPrint('Click on menu');
          if (menuPopCount <= testMenuManager!.activeDepth &&
              menuPopCount > 0) {
            testMenuManager!.popMenu(menuPopCount);
          } else {
            // Make the href is updated
            _updateMenuHash();
          }
        }

        header.append(buttonCreate()
          ..text = testMenu.name
          ..onClick.listen(clickOnMenu));
        /*
        header.append(new AnchorElement(href: '#')
          ..text = ' > ${testMenu.name}'
          ..onClick.listen((_) {
            print('$menuPopCount / $activeDepth');
            if (menuPopCount <= activeDepth && menuPopCount > 0) {
              testMenuManager.pop(menuPopCount);
            }
          }));
          */
      }
      //header.setInnerHtml(sb.toString());
      final list = listCreate();

      Element liElement;

      if (testMenuManager!.activeDepth > 0) {
        liElement = listItemCreate()
          ..append(listItemPrimaryContentCreate()
            ..append(SpanElement()
              ..className = listItemIcon
              ..appendText('-'))
            ..appendText('exit'))
          ..onClick.listen((_) {
            if (TestMenuManager.debug.on) {
              write('[mdl poping] ${testMenuManager!.menuRunners}');
            }
            testMenuManager!.popMenu();
          });
        list.children.add(liElement);
      }

      for (var i = 0; i < menu.length; i++) {
        //int index = i;
        final item = menu[i];
        liElement = listItemCreate()
          ..append(listItemPrimaryContentCreate()
            ..append(SpanElement()
              ..className = listItemIcon
              ..appendText('$i'))
            ..appendText('$item'))
          ..onClick.listen((_) {
            print("[i] running '$i $item'");
            testMenuManager!.runItem(item).then((_) {
              print("[i] done '$i $item'");
              initInputForMenu();
            });
          });
        list.children.add(liElement);
        if (debugTestMenuManager) {
          print('$i $item');
        }
      }

      displayedMenu = menu;
      menuContainer!.children
        ..clear()
        ..addAll([header, list]);

      initInputForMenu();
    }
  }

  @override
  Future<String> prompt(Object? message) {
    //String message = (message == null || message.length == 0)
    message = message == null ? 'Enter text' : '$message';
    input.value = null;
    write('$message >');
    var completer = Completer<String>.sync();
    promptCompleter = completer;
    input.label = message as String;
    input.focus();
    return completer.future;
  }
}

Future initMenuBrowser({List<String>? js}) async {
  await initTestMenuBrowser(js: js);
}

Future initTestMenuBrowser({List<String>? js}) async {
  var futures = [
    loadMdlJs(),
    loadMdlCss(),
    loadMaterialIconsCss(),
    loadStylesheet('packages/tekartik_test_menu_browser/css/test_menu_mdl.css')
  ];
  if (debugTestMenuManager) {
    print('loading js: $js');
  }
  await Future.wait(futures);
  await browser.testMenuLoadJs(js);

  _testMenuManagerBrowser = TestMenuManagerBrowser();
  _testMenuManagerBrowser!.init();

  testMenuPresenter = _testMenuManagerBrowser!;

  initTestMenuManager();
  final hash = window.location.hash;
  testMenuManager!.initCommands = TestMenuManager.initCommandsFromHash(hash);
}

TestMenuManagerBrowser? _testMenuManagerBrowser;

/// Main menu declaration
Future<void> mainMenu(void Function() declare, {List<String>? js}) async {
  await mainMenuBrowser(declare, js: js);
}

Future<void> mainMenuBrowser(void Function() declare,
    {List<String>? js}) async {
  await initTestMenuBrowser(js: js);
  declare();
}
