import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  mainMenu(args, () {
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
