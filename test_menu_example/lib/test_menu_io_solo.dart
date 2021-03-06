import 'dart:io';

import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  mainMenu(args, () {
    menu('main', () {
      item('write hola', () async {
        write('Hola');
      });
      item('echo prompt', () async {
        write('RESULT prompt: ${await prompt()}');
      });
      item('print hi', () {
        print('hi');
      });
      item('stderr echo prompt', () async {
        stderr.write(await prompt());
      }, cmd: 'e');
      menu('sub', () {
        item('print hi', () => print('hi'));
        // ignore: deprecated_member_use
        solo_item('print hi', () {
          print('hi');
        });
      });
    });
  });
}
