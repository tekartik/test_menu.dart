import 'package:tekartik_test_menu/test_menu.dart';

/// Simple key with mutable value.
class KeyValue {
  final String key;

  /// Mutable
  String? value;

  KeyValue(this.key, this.value);

  bool get valid => (value ?? '') != '';

  KeyValue cloneWithValue(String value) => KeyValue(key, value);

  @override
  String toString() => '$key: $value';
}

/// Util on list
extension KeyValueExt on KeyValue {
  void dump() {
    write(this);
  }
}

/// Util on list
extension KeyValueListExt on Iterable<KeyValue> {
  bool get valid {
    for (var kv in this) {
      if (!kv.valid) {
        return false;
      }
    }
    return true;
  }

  void dump() {
    for (var kv in this) {
      kv.dump();
    }
  }
}
