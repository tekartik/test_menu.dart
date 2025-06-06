library;

// ignore: deprecated_member_use
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
//import '

Future main() async {
  await mainMenu(() {
    item('write hola', () async {
      write('Hola');
      //write('RESULT prompt: ${await prompt()}');
    });
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });
    item('js console.log', () {
      jsTest('testConsoleLog');
    });
    item('crash', () {
      throw 'Hi';
    });
    menu('sub', () {
      item('write hi', () => write('hi'));
    });
  }, js: ['test_menu.js']);
}
