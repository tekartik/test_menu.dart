import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu/test_menu.dart';

import 'platform/platform.dart';

export 'platform/platform.dart'
    show KeyValueUniversalPlatformExt, KeyValueKeyUniversalPlatformExt;

/// Universal extension
extension KeyValueUniversalExt on KeyValue {
  /// Delete the var
  Future<void> delete() => deleteVar(key);

  /// Set the var or delete it if null
  Future<void> set(String? value) async =>
      value == null ? await delete() : await setVar(key, value);

  /// Get the var (not needed unless changed)
  String? get() => getVar(key);
}

extension KeyValueListUniversalExt on Iterable<KeyValue> {
  /// Prompt env and global save
  Future<void> promptToVar({bool? ifInvalid}) async {
    for (var kv in this) {
      if (ifInvalid ?? false) {
        if (kv.valid) {
          continue;
        }
      }
      await kv.promptToVar();
    }
  }
}

/// io helper
extension KeyValueKeyUniversalExt on String {
  KeyValue kvFromVar({String? defaultValue}) {
    return KeyValue(this, fromVar(defaultValue: defaultValue));
  }
}

/// Key values menu.
void keyValuesMenu(String name, Iterable<KeyValue> kvs) {
  menu(name, () {
    item('dump', () async {
      kvs.dump();
    });
    item('all', () async {
      await kvs.promptToVar();
      write('done all kvs: $kvs');
    });
    item('prompt invalids', () async {
      await kvs.promptToVar(ifInvalid: true);
    });
    void allKv() {
      for (var kv in kvs) {
        item('update ${kv.key}', () async {
          var newKv = await kv.promptToVar();
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
          await deleteVar(kv.key);
          kv.value = null;

          write(kv);
        });
      }
    });
  });
}
