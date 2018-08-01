import 'package:tekartik_test_menu_io/test_menu_io.dart';
import 'package:tekartik_test_menu/test.dart';

main(List<String> args) async {
  mainMenu(args, () {
    // ignore: deprecated_member_use
    solo_test('root test', () {
      expect(true, isFalse);
    });

    menu('main', () {
      item("write hola", () async {
        write('Hola');
      }, cmd: "a");
      item("echo prompt", () async {
        write('RESULT prompt: ${await prompt()}');
      });
      item("print hi", () {
        print('hi');
      });
      menu('sub', () {
        item("print hi", () => print('hi'));
      }, cmd: 's');
    });
  });
}
