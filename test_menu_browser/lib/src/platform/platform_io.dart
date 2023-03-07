import 'package:tekartik_test_menu_io/test_menu_io.dart' as io;

Future<void> platformMainMenu(
    List<String> arguments, void Function() declare) async {
  io.mainMenu(arguments, declare);
}
