import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu/test_menu.dart';
import 'package:tekartik_test_menu_browser/src/vars_browser.dart';

extension KeyValueBrowserExt on KeyValue {
  /// Prompt env and global save
  Future<KeyValue> promptToLocalStorage() async {
    var newValue = await prompt('$key${valid ? ' ($value)' : ''}') ?? '';
    if (newValue.isNotEmpty) {
      setLocalStorageVar(key, newValue);
      value = newValue;
    }
    return this;
  }
}

extension KeyValueListBrowserExt on Iterable<KeyValue> {
  /// Prompt env and global save
  Future<void> promptToLocalStorage({bool? ifInvalid}) async {
    for (var kv in this) {
      if (ifInvalid ?? false) {
        if (kv.valid) {
          continue;
        }
      }
      await kv.promptToLocalStorage();
    }
  }
}

final _exportCache = <String, String?>{};

/// io helper
extension KeyValueKeyBrowserExt on String {
  KeyValue kvFromLocalStorage({String? defaultValue}) {
    return KeyValue(this, fromLocalStorage(defaultValue: defaultValue));
  }

  String? fromLocalStorage({String? defaultValue}) {
    var value = _exportCache[this] ??= getLocalStorageVar(this) ?? defaultValue;
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
      await kvs.promptToLocalStorage();
    });
    item('prompt invalids', () async {
      await kvs.promptToLocalStorage(ifInvalid: true);
    });
    void allKv() {
      for (var kv in kvs) {
        item('update ${kv.key}', () async {
          var newKv = await kv.promptToLocalStorage();
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
          deleteLocalStorageVar(kv.key);
          kv.value = null;

          write(kv);
        });
      }
    });
  });
}
