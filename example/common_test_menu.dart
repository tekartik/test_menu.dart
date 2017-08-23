library test_menu_console_interactive_test;

import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_test_menu/test_menu.dart';
//import 'package:tekartik_test_menu/src/common.dart';

// basic "0;-"
main() async {
  menu('main', () {
    item("write hola", () async {
      write('Hola');
    });
    item("prompt", () async {
      write('RESULT prompt: ${await prompt()}');
    });
    item("print hi", () {
      print('hi');
    });
    item("crash", () {
      throw "crash";
    });
    menu('sub', () {
      item("print hi", () => print('hi'));
    });
    item("write 250 lines", () {
      for (int i = 1; i <= 250; i++) {
        write("$i: this is a line, but only 100 of them will be displayed");
      }
    });

    menu('slow_sub', () {
      enter(() async {
        write('enter sub');
        await sleep(1000);
        write('enter sub done');
      });
      leave(() async {
        write('leave sub');
        await sleep(1000);
        write('leave sub done');
      });
      item("write hi", () {
        write('hi from slow_sub');
      });
    });
  });
}
