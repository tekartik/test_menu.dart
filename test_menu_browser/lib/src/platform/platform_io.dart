import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart' as io;

Future<void> platformMainMenu(
    List<String> arguments, void Function() declare) async {
  io.mainMenu(arguments, declare);
}

extension KeyValueUniversalPlatformExt on KeyValue {
  /// Prompt env and global save
  Future<KeyValue> promptToVar() => promptToEnv();
}

extension KeyValueKeyUniversalPlatformExt on String {
  String? fromVar({String? defaultValue}) =>
      fromEnv(defaultValue: defaultValue);
}

Future<void> deleteVar(String key) => deleteEnvVar(key);
Future<void> setVar(String key, String value) => setEnvVar(key, value);
String? getVar(String key) => getEnvVar(key);
