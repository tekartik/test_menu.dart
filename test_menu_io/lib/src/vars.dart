import 'package:process_run/shell.dart';

/// Set an env var
Future<void> setEnvVar(String key, String value) async {
  await Shell().run(
      'dart pub global run process_run:shell env var set ${shellArgument(key)} ${shellArgument(value)}');
}

/// Delete an env var
Future<void> deleteEnvVar(String key) async {
  await Shell().run(
      'dart pub global run process_run:shell env var delete ${shellArgument(key)}');
}

/// Return env var.
String? getEnvVar(String key) {
  return ShellEnvironment().vars[key];
}
