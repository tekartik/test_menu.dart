library;

import 'package:process_run/shell.dart';
//import 'package:tekartik_test_menu/src/common_import.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

import 'common_test_menu.dart' as common_test_menu;

void main(List<String> arguments) {
  var count =
      (arguments.isNotEmpty ? int.tryParse(arguments.first) : null) ?? 1;
  //TestMenuManager.debug.on = true;

  initTestMenuConsole(arguments);

  common_test_menu.main();
  item('spawn this menu again $count', () async {
    await usingSharedStdIn(() async {
      await Shell(stdin: sharedStdIn)
          .run('dart run lib/test_menu_io_interactive_tests.dart ${count + 1}');
    });
  });
  /*

  TestMenu subMenu = new TestMenu("sub");
  subMenu.add("print hi", () => print('hi'));

  TestMenu menu = new TestMenu("main");
  menu.add("print hi", () => print('hi'));
  menu.addMenu(subMenu);
  showTestMenu(menu);
  */
}
