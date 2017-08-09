import 'package:tekartik_test_menu/test_menu_io.dart';
import 'dart:io';

main(List<String> args) async {
  mainMenu(args, () {
    menu('main', () {
      item("write hola", () async {
        write('Hola');
      });
      item("echo prompt", () async {
        write('RESULT prompt: ${await prompt()}');
      });
      item("print hi", () {
        print('hi');
      });
      item("stderr echo prompt", () async {
        stderr.write(await prompt());
      }, cmd: "e");
      menu('sub', () {
        item("print hi", () => print('hi'));
      });
    });
  });
}
