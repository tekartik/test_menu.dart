import 'dart:io';

import 'package:tekartik_test_menu_io/test_menu_io.dart';

Future main(List<String> args) async {
  mainMenu(args, () {
    menu('main', () {
      item('write hola', () async {
        write('Hola');
      });
      item('echo prompt', () async {
        write('RESULT prompt: ${await prompt()}');
      });
      item('print hi', () {
        writeln('hi');
      });
      item('stderr echo prompt', () async {
        stderr.write(await prompt());
      }, cmd: 'e');
      menu('sub', () {
        enter(() async {
          writeln('enter sub');
        });
        leave(() async {
          writeln('leave sub');
        });
        item('print hi', () => writeln('hi'));
      });
    });
  });
}
