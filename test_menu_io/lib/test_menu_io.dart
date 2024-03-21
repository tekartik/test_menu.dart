library;

import 'package:dev_build/menu/menu_io.dart';

export 'package:dev_build/menu/menu.dart';
export 'package:dev_build/menu/menu_io.dart';

/// Compat.
export 'package:dev_build/src/menu/io/menu_io_console.dart'
    show usingSharedStdIn;

/// Compat
Future<void> testMenuRun() async {
  await menuRun();
}

void initTestMenuConsole(List<String> arguments) async {
  initMenuConsole(arguments);
}

/// Compat
void mainMenu(List<String> arguments, void Function() declare) {
  mainMenuConsole(arguments, declare);
}
