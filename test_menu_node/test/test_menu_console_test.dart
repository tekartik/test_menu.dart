@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// Run the node console menu (its io implementation) with [arguments].
Future<ProcessResult> runConsoleMenu(List<String> arguments) async {
  var process = await Process.start(Platform.resolvedExecutable, [
    'test/src/console_menu_main.dart',
    ...arguments,
  ]);
  // Arguments end with an exit, never wait on stdin.
  await process.stdin.close();
  var out = process.stdout.transform(utf8.decoder).join();
  var err = process.stderr.transform(utf8.decoder).join();
  var exitCode = await process.exitCode.timeout(const Duration(minutes: 1));
  return ProcessResult(process.pid, exitCode, await out, await err);
}

void main() {
  group('mainMenuConsole', () {
    test('help names the exit command', () async {
      var result = await runConsoleMenu(['-h']);
      expect(result.exitCode, 0);
      expect(result.stdout, contains('dart test_menu.dart 0 .'));
    });
    test('run items then exit', () async {
      var result = await runConsoleMenu(['0', '.']);
      expect(result.exitCode, 0);
      expect(result.stdout, contains('hi'));
      expect(result.stdout, isNot(contains('errorValue')));
    });
    test('command error reported', () async {
      var result = await runConsoleMenu(['1', 'boom', '0', '.', '.']);
      expect(result.exitCode, 0);
      expect(result.stdout, contains('command failed: boom'));
      expect(result.stdout, contains('item failed'));
    });
  });
}
