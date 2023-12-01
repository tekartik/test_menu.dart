import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu/test_menu.dart';
import 'package:tekartik_test_menu_io/src/vars.dart';

extension KeyValueIoExt on KeyValue {
  /// Prompt env and global save
  Future<KeyValue> promptToEnv() async {
    var newValue = await prompt('$key${valid ? ' ($value)' : ''}') ?? '';
    if (newValue.isNotEmpty) {
      await setToEnv(newValue);
    }
    return this;
  }

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
  Future<void> promptToEnv({bool? ifInvalid}) async {
    for (var kv in this) {
      if (ifInvalid ?? false) {
        if (kv.valid) {
          continue;
        }
      }
      await kv.promptToEnv();
    }
  }
}

final _exportCache = <String, String?>{};

/// io helper
extension KeyValueKeyIoExt on String {
  KeyValue kvFromEnv({String? defaultValue}) {
    return KeyValue(this, fromEnv(defaultValue: defaultValue));
  }

  String? fromEnv({String? defaultValue}) {
    var value = _exportCache[this] ??= getEnvVar(this) ?? defaultValue;
    return value;
  }
}

/// Key values menu.
void keyValuesMenu(String name, Iterable<KeyValue> kvs) {
  menu(name, () {
    item('dump', () async {
      kvs.dump();
    });
    item('all', () async {
      await kvs.promptToEnv();
    });
    item('prompt invalids', () async {
      await kvs.promptToEnv(ifInvalid: true);
    });
    void allKv() {
      for (var kv in kvs) {
        item('update ${kv.key}', () async {
          var newKv = await kv.promptToEnv();
          write(newKv);
        });
      }
    }

    if (kvs.length < 6) {
      allKv();
    } else {
      menu('one by one', () {
        allKv();
      });
    }
    item('clear one by one', () {
      for (var kv in kvs) {
        item('delete ${kv.key}', () async {
          await deleteEnvVar(kv.key);
          kv.value = null;

          write(kv);
        });
      }
    });
  });
}
