import 'package:tekartik_test_menu_browser/key_value_universal.dart';
import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

var kvTestValue = 'TestValue'.kvFromVar();
Future main(List<String> arguments) async {
  await mainMenu(arguments, () {
    keyValuesMenu('kv', [kvTestValue]);
    item('write hola', () async {
      write('!Hola');
      //write('RESULT prompt: ${await prompt()}');
    });
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });
  });
}
