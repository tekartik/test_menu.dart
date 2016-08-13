library test_menu;

import 'package:tekartik_test_menu/test_menu_mdl_browser.dart';


main() async {
  await initTestMenuBrowser(js: ['test_menu.js']);

  menu('main', () {
    item("write hola", () async {
      write('Hola');
      //write('RESULT prompt: ${await prompt()}');
    });
    item("prompt", () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });
    item("js console.log", () {
      js_test('testConsoleLog');
    });
    item("print hi", () {
      print('hi');
    });
    menu('sub', () {
      item("print hi", () => print('hi'));
    });
  });
}