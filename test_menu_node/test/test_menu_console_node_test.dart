@TestOn('vm')
library;

import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_app_node_build/app_build.dart';
import 'package:test/test.dart';

/// Compiles test/src/console_menu_main.dart for node and runs it.
void main() {
  var node = whichSync('node');
  group(
    'mainMenuConsole on node',
    () {
      late Directory dir;
      late String js;
      setUpAll(() async {
        dir = await Directory.systemTemp.createTemp('test_menu_node');
        js = dir.uri.resolve('console_menu_main.js').toFilePath();
        await nodePackageCompileJs(
          '.',
          input: 'test/src/console_menu_main.dart',
          output: js,
        );
      });
      tearDownAll(() async {
        await dir.delete(recursive: true);
      });

      /// Runs the compiled menu with [arguments], stdin closed.
      Future<ProcessResult> runNodeMenu(List<String> arguments) {
        return runExecutableArguments(node!, [
          js,
          ...arguments,
        ], stdin: const Stream<List<int>>.empty());
      }

      test('arguments replayed as commands', () async {
        // dart2js gives an empty list to main on node: the arguments come
        // from process.argv.
        var result = await runNodeMenu(['0', '.']);
        expect(result.exitCode, 0);
        // The line written by the item, not its name in the menu ('0 hi').
        expect(result.outLines, contains('hi'));
        expect(result.outText, isNot(contains('errorValue')));
      });
      test('help', () async {
        var result = await runNodeMenu(['-h']);
        expect(result.exitCode, 0);
        expect(result.outText, contains('0 .'));
      });
    },
    skip: node == null ? 'node not found' : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
