import 'package:dev_test/build_support.dart';
import 'package:process_run/shell.dart';

Future<void> _processRunReady = () async {
  await checkAndActivatePackage('process_run');
}();

/// Set an env var
Future<void> setEnvVar(String key, String value) async {
  await _processRunReady;
  await Shell().run(
      'dart pub global run process_run:shell env var set ${shellArgument(key)} ${shellArgument(value)}');
}

/// Delete an env var
Future<void> deleteEnvVar(String key) async {
  await _processRunReady;
  await Shell().run(
      'dart pub global run process_run:shell env var delete ${shellArgument(key)}');
}

/// Return env var.
String? getEnvVar(String key) {
  return ShellEnvironment().vars[key];
}
