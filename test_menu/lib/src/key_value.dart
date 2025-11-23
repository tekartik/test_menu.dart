import 'package:tekartik_test_menu/test_menu.dart';

/// Simple key with mutable value.
class KeyValue {
  /// The key.
  final String key;

  /// Mutable
  String? value;

  /// Constructor
  KeyValue(this.key, this.value);

  /// true if value is not null and not empty.
  bool get valid => (value ?? '') != '';

  /// Clone with a new value.
  KeyValue cloneWithValue(String value) => KeyValue(key, value);

  @override
  String toString() => '$key: $value';
}

/// Util on list
extension KeyValueExt on KeyValue {
  /// Dump the key value.
  void dump() {
    write(this);
  }
}

/// Util on list
extension KeyValueListExt on Iterable<KeyValue> {
  /// true if all key values are valid.
  bool get valid {
    for (var kv in this) {
      if (!kv.valid) {
        return false;
      }
    }
    return true;
  }

  /// Dump the key values.
  void dump() {
    for (var kv in this) {
      kv.dump();
    }
  }
}
