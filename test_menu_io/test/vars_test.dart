import 'package:dev_build/build_support.dart';
import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:test/test.dart';

Future<void> main() async {
  setUpAll(() async {
    await checkAndActivatePackage('process_run', verbose: true);
  });
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
