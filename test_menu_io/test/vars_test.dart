import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test('vars test', () async {
    var key = 'eAEVYA0YTid8HNjBbdMb';
    await deleteEnvVar(key);
    expect(getEnvVar(key), isNull);

    await setEnvVar(key, 'value1');
    expect(getEnvVar(key), 'value1');

    await setEnvVar(key, 'value2');
    expect(getEnvVar(key), 'value2');

    await deleteEnvVar(key);
    expect(getEnvVar(key), isNull);
  });
}
