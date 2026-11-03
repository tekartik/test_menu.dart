@TestOn('vm')
library;

import 'dart:io';

import 'package:dev_build/build_support.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var key = 'eAEVYA0YTid8HNjBbdMb';
  late Directory tempDir;
  setUpAll(() async {
    await checkAndActivatePackage('process_run', verbose: true);
    tempDir = await Directory.systemTemp.createTemp('test_menu_io_vars_');
    // Never the real user env file (~/.config/tekartik/process_run/env.yaml)
    // nor the local one (.local/ds_env.yaml)
    var userEnvFile = File('${tempDir.path}/user_env.yaml');
    var localEnvFile = File('${tempDir.path}/local_env.yaml');
    for (var file in [userEnvFile, localEnvFile]) {
      await file.writeAsString('');
    }
    platformEnvironment = {
      ...platformEnvironment,
      'TEKARTIK_PROCESS_RUN_USER_ENV_FILE_PATH': userEnvFile.path,
      'TEKARTIK_PROCESS_RUN_LOCAL_ENV_FILE_PATH': localEnvFile.path,
    }..remove(key);
  });
  tearDownAll(() async {
    platformEnvironment = null;
    await tempDir.delete(recursive: true);
  });
  test('vars test', () async {
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
