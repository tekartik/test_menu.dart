import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

Future main() async {
  await initTestMenuBrowser();

  item('write hola', () async {
    write('!Hola');
    //write('RESULT prompt: ${await prompt()}');
  });
  item('prompt', () async {
    write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
  });
}
