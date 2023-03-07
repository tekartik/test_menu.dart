import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

Future main(List<String> arguments) async {
  await mainMenu(arguments, () {
    item('write hola', () async {
      write('!Hola');
      //write('RESULT prompt: ${await prompt()}');
    });
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });
  });
}
