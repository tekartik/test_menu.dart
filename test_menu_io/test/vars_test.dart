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
    await deleteEnvVar(key, user: true);
    expect(getEnvVar(key), isNull);

    await setEnvVar(key, 'value1_user', user: true);

    expect(getEnvVar(key), 'value1_user');
    await setEnvVar(key, 'value1_local');

    expect(getEnvVar(key), 'value1_local');
    await setEnvVar(key, 'value1_local2');
    expect(getEnvVar(key), 'value1_local2');
    await deleteEnvVar(key);
    expect(getEnvVar(key), 'value1_user');

    await setEnvVar(key, 'value1_user2', user: true);
    expect(getEnvVar(key), 'value1_user2');

    await deleteEnvVar(key);
    await deleteEnvVar(key, user: true);
    expect(getEnvVar(key), isNull);
  });
}
