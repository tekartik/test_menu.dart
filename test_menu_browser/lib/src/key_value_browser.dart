import 'package:tekartik_browser_utils/storage_utils.dart';
import 'package:tekartik_test_menu/key_value.dart';
// ignore: implementation_imports
import 'package:tekartik_test_menu/src/key_value_menu.dart';

extension KeyValueBrowserExt on KeyValue {
  /// Prompt env and global save
  Future<KeyValue> promptToLocalStorage() =>
      keyValuePrompt(this, (value) async {
        webLocalStorageSet(key, value);
        this.value = value;
      });
}

extension KeyValueListBrowserExt on Iterable<KeyValue> {
  /// Prompt env and global save
  Future<void> promptToLocalStorage({bool? ifInvalid}) => keyValuesPrompt(
    this,
    (kv) => kv.promptToLocalStorage(),
    ifInvalid: ifInvalid,
  );
}

/// io helper
extension KeyValueKeyBrowserExt on String {
  KeyValue kvFromLocalStorage({String? defaultValue}) {
    return KeyValue(this, fromLocalStorage(defaultValue: defaultValue));
  }

  /// Read from the local storage (not cached, like the io env).
  String? fromLocalStorage({String? defaultValue}) {
    return webLocalStorageGet(this) ?? defaultValue;
  }
}

/// Key values menu.
void keyValuesMenu(String name, Iterable<KeyValue> kvs) {
  keyValuesMenuImpl(
    name,
    kvs,
    promptKv: (kv) => kv.promptToLocalStorage(),
    deleteKv: (kv) async {
      webLocalStorageRemove(kv.key);
      kv.value = null;
    },
  );
}
