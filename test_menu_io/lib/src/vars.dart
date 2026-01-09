import 'package:process_run/shell.dart';

bool _userTolocal(bool? user) => !(user ?? false);

/// Set an env var
/// local by default unless user is true
Future<void> setEnvVar(String key, String value, {bool? user}) async {
  await Shell().shellVarOverride(key, value, local: _userTolocal(user));
}

/// Delete an env var
/// local by default unless user is true
Future<void> deleteEnvVar(String key, {bool? user}) async {
  await Shell().shellVarOverride(key, null, local: _userTolocal(user));
}

/// Return env var.
String? getEnvVar(String key) {
  return ShellEnvironment().vars[key];
}
