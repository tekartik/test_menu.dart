library tekartik_test_menu_mdl_browser;

import 'package:tekartik_mdl_js/mdl_button.dart';
import 'package:tekartik_mdl_js/mdl_classes.dart';
import 'package:tekartik_mdl_js/mdl_js_loader.dart';
import 'package:tekartik_mdl_js/mdl_list.dart';
import 'package:tekartik_mdl_js/mdl_textfield.dart';
import 'package:platform_context/context_browser.dart';
import 'package:tekartik_common_utils/out_buffer.dart';
import 'test_menu_browser.dart' as browser;

import 'src/common_browser.dart';
export 'src/common_browser.dart';
import 'test_menu.dart';
import 'test_menu_browser.dart' as common_browser;

export 'test_menu.dart';
export 'test_menu_browser.dart' show js_test;
//import 'package:tekartik_mdl_js/mdl_js.dart';

const String CONTAINER_ID = "tekartik_test_menu_container";
const String MENU_ID = "test_menu";
const String OUTPUT_ID = "output";
const String INPUT_ID = "input";

// can be extended
class TestMenuManagerBrowser extends common_browser.TestMenuManagerBrowser {
  TestMenu displayedMenu = null;
  Element container = null;
  Element output = null;
  Element menuContainer = null;

  TextField input = null;

  PlatformContext platformContext = browserPlatformContext;
  bool get isMobile => platformContext.browser.isMobile;

  var outBuffer = new OutBuffer(100);

  void write(Object message) {
    String text = "$message";
    if (debugTestMenuManager) {
      print("writing $text");
    }

    outBuffer.add(text);
    output.text = outBuffer.toString();
    autoScroll();
  }

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

  void initInputForMenu() {
    input.label = "Your choice";
    input.value = "";

    if (!isMobile) {
      input.focus();
    }
  }

  void findContainer() {
    if (container == null) {
      //devPrint(browserPlatformContext);
      /*
      devPrint(platformContext);
      devPrint(platformContext.browser);
      devPrint(platformContext.browser.isMobile);
      */
      //devPrint(isMobile);

      container = document.getElementById(CONTAINER_ID);
      if (container == null) {
        container = new DivElement()..id = CONTAINER_ID;
        document.body.children.add(container);

        menuContainer = new DivElement()..id = MENU_ID;

        output = new PreElement()..id = OUTPUT_ID;

        var form = new FormElement();
        form.setAttribute("action", "#");

        input = new TextField(id: INPUT_ID, floatingLabel: true);
        form.append(input.element);
        form.onSubmit.listen((Event e) {
          //print("on submit: ${input.value}");
          String value = input.value;
          input.value = null;
          e.preventDefault();
          if (promptCompleter != null) {
            promptCompleter.complete(value);
            promptCompleter = null;

            initInputForMenu();
          } else {
            if (value == '-') {
              testMenuManager.pop();
            } else {
              int index = int.parse(value, onError: (_) => -1);
              //print("on submit: $value ${index}");
              if (index >= 0) {
                if (displayedMenu != null) {
                  runItem(displayedMenu[index]);
                }
              }
            }
          }
        });

        container.children.addAll([output, menuContainer, form]);
      }
    }
  }

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

  void autoScroll() {
    window.scrollTo(0, document.body.scrollHeight);
  }

  // for href
  List<String> getMenuStackNames([TestItem item]) {
    List<String> list = new List();

    TestMenu lastMenu = null;
    for (int i = stackMenus.length - 1; i >= 0; i--) {
      TestMenu menu = stackMenus[i];

      int index;

      if (lastMenu == null) {
        lastMenu = activeMenu;
        if (item == null) {
          continue;
        }
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
    return list;
  }

  @override
  void onProcessItem(TestItem item) {
    window.location.hash = "#${getMenuStackNames(item).join('_')}";
    // process after setting the hash to allow reload in case of crash in processing
    super.onProcessItem(item);
  }

  //@override
  void init() {
    findContainer();
  }

  void _updateMenuHash() {
    window.location.hash = "#${getMenuStackNames().join('_')}";
  }

  void displayMenu(TestMenu menu) {
    findContainer();

    if (displayedMenu != menu) {
      //Element header = new HeadingElement.h4();
      Element header = new DivElement();

      _updateMenuHash();

      //StringBuffer sb = new StringBuffer();
      int popCount = activeDepth;
      for (TestMenu testMenu in testMenuManager.stackMenus) {
        int menuPopCount = popCount--;
        _clickOnMenu([_]) {
          //devPrint("Click on menu");
          if (menuPopCount <= activeDepth && menuPopCount > 0) {
            testMenuManager.pop(menuPopCount);
          } else {
            // Make the href is updated
            _updateMenuHash();
          }
        }

        header.append(buttonCreate()
          ..text = testMenu.name
          ..onClick.listen(_clickOnMenu));
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
      Element list = listCreate();

      Element liElement;

      if (activeDepth > 0) {
        liElement = listItemCreate()
          ..append(listItemPrimaryContentCreate()
            ..append(new SpanElement()
              ..className = listItemIcon
              ..appendText('-'))
            ..appendText("exit"))
          ..onClick.listen((_) {
            testMenuManager.pop();
          });
        list.children.add(liElement);
      }

      for (int i = 0; i < menu.length; i++) {
        //int index = i;
        TestItem item = menu[i];
        liElement = listItemCreate()
          ..append(listItemPrimaryContentCreate()
            ..append(new SpanElement()
              ..className = listItemIcon
              ..appendText('$i'))
            ..appendText("${item}"))
          ..onClick.listen((_) {
            // print("running '$index ${item}'");
            runItem(item).then((_) {
              initInputForMenu();
            });
          });
        list.children.add(liElement);
        if (debugTestMenuManager) {
          print('$i ${item}');
        }
      }

      displayedMenu = menu;
      menuContainer.children
        ..clear()
        ..addAll([header, list]);

      initInputForMenu();
    }
  }

  void showMenu(TestMenu menu) {
    displayMenu(menu);
    onProcessMenu(menu);
  }

  Completer<String> promptCompleter;

  @override
  Future<String> prompt(Object message) {
    //String message = (message == null || message.length == 0)
    message = message == null ? "Enter text" : "$message";
    input.value = null;
    write("$message >");
    var completer = new Completer<String>.sync();
    promptCompleter = completer;
    input.label = message;
    input.focus();
    return completer.future;
  }
}

Future initTestMenuBrowser({List<String> js}) async {
  var futures = [
    loadMdlJs(),
    loadMdlCss(),
    loadMaterialIconsCss(),
    loadStylesheet("packages/tekartik_test_menu/css/test_menu_mdl.css")
  ];
  if (debugTestMenuManager) {
    print("loading js: $js");
  }
  await Future.wait(futures);
  await browser.testMenuLoadJs(js);

  _testMenuManagerBrowser = new TestMenuManagerBrowser();
  _testMenuManagerBrowser.init();
}

TestMenuManagerBrowser _testMenuManagerBrowser;
