import 'package:tekartik_test_menu/key_value.dart';
import 'package:tekartik_test_menu/test_menu.dart';

/// Prompt a key value returning it.
typedef KeyValuePrompt = Future<KeyValue> Function(KeyValue kv);

/// Prompt a new value for [kv], saved with [save] unless empty.
///
/// [save] must also update the value of [kv].
Future<KeyValue> keyValuePrompt(
  KeyValue kv,
  Future<void> Function(String value) save,
) async {
  var newValue = await prompt('${kv.key}${kv.valid ? ' (${kv.value})' : ''}');
  if (newValue.isNotEmpty) {
    await save(newValue);
  }
  return kv;
}

/// Prompt each key value with [promptKv], only the invalid ones if
/// [ifInvalid] is true.
Future<void> keyValuesPrompt(
  Iterable<KeyValue> kvs,
  KeyValuePrompt promptKv, {
  bool? ifInvalid,
}) async {
  for (var kv in kvs) {
    if ((ifInvalid ?? false) && kv.valid) {
      continue;
    }
    await promptKv(kv);
  }
}

/// Key values menu, [promptKv] prompts and saves one value, [deleteKv]
/// deletes one value.
void keyValuesMenuImpl(
  String name,
  Iterable<KeyValue> kvs, {
  required KeyValuePrompt promptKv,
  required Future<void> Function(KeyValue kv) deleteKv,
}) {
  menu(name, () {
    item('dump', () {
      kvs.dump();
    });
    item('all', () async {
      await keyValuesPrompt(kvs, promptKv);
      write('done all kvs: $kvs');
    });
    item('prompt invalids', () async {
      await keyValuesPrompt(kvs, promptKv, ifInvalid: true);
    });
    void allKv() {
      for (var kv in kvs) {
        item('update ${kv.key}', () async {
          write(await promptKv(kv));
        });
      }
    }

    if (kvs.length < 6) {
      allKv();
    } else {
      menu('one by one', allKv);
    }
    menu('clear one by one', () {
      for (var kv in kvs) {
        item('delete ${kv.key}', () async {
          await deleteKv(kv);
          write(kv);
        });
      }
    });
  });
}
