import 'package:tekartik_test_menu_io/test_menu_io.dart';

void main(List<String> args) {
  // TestMenuManager.debug.on = true;
  mainMenu(args, () {
    command((command) {
      writeln('Command entered: $command');
    });
    menu('main', () {
      item('write hola', () async {
        write('Hola');
      }, cmd: 'a');
      item('echo prompt', () async {
        writeln('RESULT prompt: ${await prompt()}');
      });
      item('print hi', () {
        writeln('hi');
      });
      menu('sub', () {
        item('print hi', () => writeln('hi'));
      }, cmd: 's');
      item('custom menu', () async {
        writeln('before custom menu');
        await showMenu(() {
          item('custom item', () {});
        });
        writeln('after custom menu');
      });
    });
  });
}
