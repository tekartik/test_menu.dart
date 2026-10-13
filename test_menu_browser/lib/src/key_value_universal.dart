import 'package:tekartik_test_menu/key_value.dart';
// ignore: implementation_imports
import 'package:tekartik_test_menu/src/key_value_menu.dart';

import 'platform/platform.dart';

export 'platform/platform.dart'
    show KeyValueUniversalPlatformExt, KeyValueKeyUniversalPlatformExt;

/// Universal extension
extension KeyValueUniversalExt on KeyValue {
  /// Delete the var
  Future<void> delete() async {
    await deleteVar(key);
    value = null;
  }

  /// Set the var or delete it if null
  Future<void> set(String? value) async {
    if (value == null) {
      await delete();
      return;
    }
    await setVar(key, value);
    this.value = value;
  }

  /// Get the var (not needed unless changed)
  String? get() {
    value = getVar(key);
    return value;
  }
}

extension KeyValueListUniversalExt on Iterable<KeyValue> {
  /// Prompt env and global save
  Future<void> promptToVar({bool? ifInvalid}) =>
      keyValuesPrompt(this, (kv) => kv.promptToVar(), ifInvalid: ifInvalid);
}

/// io helper
extension KeyValueKeyUniversalExt on String {
  KeyValue kvFromVar({String? defaultValue}) {
    return KeyValue(this, fromVar(defaultValue: defaultValue));
  }
}

/// Key values menu.
void keyValuesMenu(String name, Iterable<KeyValue> kvs) {
  keyValuesMenuImpl(
    name,
    kvs,
    promptKv: (kv) => kv.promptToVar(),
    deleteKv: (kv) => kv.delete(),
  );
}
