library;

// ignore: deprecated_member_use
import 'package:tekartik_test_menu_browser/test_menu_browser_compat.dart';
//import '

void main() async {
  await initTestMenuBrowser(jsFiles: ['test_menu.js']);

  menu('main', () {
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
    item('print hi', () {
      print('hi');
    });
    item('crash', () {
      throw 'Hi';
    });
    menu('sub', () {
      item('print hi', () => print('hi'));
    });
  });
}
