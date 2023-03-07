import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu_browser/key_value_browser.dart';
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

Future<void> platformMainMenu(
    List<String> arguments, void Function() declare) async {
  //if (isRunningAsJavascript) {}
  await initTestMenuBrowser();
  declare();
}

extension KeyValueUniversalPlatformExt on KeyValue {
  /// Prompt env and global save
  Future<KeyValue> promptToVar() => promptToLocalStorage();
}

extension KeyValueKeyUniversalPlatformExt on String {
  String? fromVar({String? defaultValue}) =>
      fromLocalStorage(defaultValue: defaultValue);
}

//void deleteVar(String key) => deleteLocalStorageVar(key);
Future<void> deleteVar(String key) async => deleteLocalStorageVar(key);

Future<void> setVar(String key, String value) async =>
    setLocalStorageVar(key, value);

String? getVar(String key) => getLocalStorageVar(key);
