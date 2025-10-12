import 'package:tekartik_test_menu_node/test_menu_console.dart';

Future main(List<String> arguments) async {
  mainMenuConsole(arguments, () {
    item('write hola', () async {
      write('Hola');
      //write('RESULT prompt: ${await prompt()}');
    });
    item('prompt', () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });
    item('prompt twice', () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });

    item('crash', () {
      throw 'Hi';
    });

    menu('sub', () {
      item('write hi', () => write('hi'));
    });

    menu('handle command', () {
      command((command) {
        write('Got command: $command');
      });
      item('write hola', () {
        write('Hola');
      });
    });

    item('dynamic menu', () async {
      await showMenu(() {
        item('dynamic item', () {
          write('dynamic');
        });
      });
    });
  });
}
