import 'package:tekartik_test_menu/key_value.dart';
// ignore: implementation_imports
import 'package:tekartik_test_menu/src/key_value_menu.dart';
import 'package:tekartik_test_menu_io/src/vars.dart';

extension KeyValueIoExt on KeyValue {
  /// Prompt env and global save
  Future<KeyValue> promptToEnv() => keyValuePrompt(this, setToEnv);

  Future<void> setToEnv(String value) async {
    await setEnvVar(key, value);
    this.value = value;
  }

  Future<void> deleteFromEnv() async {
    await deleteEnvVar(key);
    value = null;
  }
}

extension KeyValueListIoExt on Iterable<KeyValue> {
  /// Prompt env and global save
  Future<void> promptToEnv({bool? ifInvalid}) =>
      keyValuesPrompt(this, (kv) => kv.promptToEnv(), ifInvalid: ifInvalid);
}

/// io helper
extension KeyValueKeyIoExt on String {
  KeyValue kvFromEnv({String? defaultValue}) {
    return KeyValue(this, fromEnv(defaultValue: defaultValue));
  }

  String? fromEnv({String? defaultValue}) {
    var value = getEnvVar(this) ?? defaultValue;
    return value;
  }
}

/// Key values menu.
void keyValuesMenu(String name, Iterable<KeyValue> kvs) {
  keyValuesMenuImpl(
    name,
    kvs,
    promptKv: (kv) => kv.promptToEnv(),
    deleteKv: (kv) => kv.deleteFromEnv(),
  );
}
