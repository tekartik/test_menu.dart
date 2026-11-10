@TestOn('vm')
library;

import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:test/test.dart';

/// Run the node console menu (its io implementation) with [arguments].
Future<ProcessResult> runConsoleMenu(List<String> arguments) {
  // Arguments end with an exit, never wait on stdin: no input, its end at
  // once.
  return Shell(
        stdin: const Stream<List<int>>.empty(),
        verbose: false,
        throwOnError: false,
      )
      .runExecutableArguments(Platform.resolvedExecutable, [
        'test/src/console_menu_main.dart',
        ...arguments,
      ])
      .timeout(const Duration(minutes: 1));
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
