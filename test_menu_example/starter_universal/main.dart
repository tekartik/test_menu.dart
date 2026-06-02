library;

import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

//import '

void main(List<String> arguments) async {
  await mainMenuUniversal(arguments, () {
    menu('main', () {
      item('write hola', () async {
        write('Hola');
        //write('RESULT prompt: ${await prompt()}');
      });
      item('prompt', () async {
        write(
          'RESULT prompt: ${await prompt('Some text please then [ENTER]')}',
        );
      });

      item('print hi', () {
        writeln('hi');
      });
      item('crash', () {
        throw StateError('crash');
      });
      menu('sub', () {
        item('print hi', () => writeln('hi'));
      });
    });
  });
}
