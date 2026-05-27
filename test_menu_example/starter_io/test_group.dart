import 'package:tekartik_test_menu/test.dart'; // ignore: depend_on_referenced_packages
import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  mainMenu(args, () {
    // ignore: invalid_use_of_do_not_submit_member
    solo_test('root test', () {
      expect(true, isFalse);
    });

    menu('main', () {
      item('write hola', () async {
        write('Hola');
      }, cmd: 'a');
      item('echo prompt', () async {
        write('RESULT prompt: ${await prompt()}');
      });
      item('print hi', () {
        writeln('hi');
      });
      menu('sub', () {
        item('print hi', () => writeln('hi'));
      }, cmd: 's');
    });
  });
}
