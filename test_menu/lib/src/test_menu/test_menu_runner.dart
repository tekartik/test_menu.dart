import 'package:stack_trace/stack_trace.dart';
import 'package:tekartik_test_menu/src/common_import.dart';
import 'package:tekartik_test_menu/src/expect.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/test_menu.dart';
import 'package:tekartik_test_menu/test_menu_presenter.dart';

class TestMenuRunner {
  final TestMenu menu;
  final TestMenuRunner? parent;
  final _doneCompleter = Completer<void>.sync();

  /// Completed when poped
  Future<void> get done => _doneCompleter.future;

  void _complete() {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  @override
  String toString() => menu.toString();

  bool entered = false;

  TestMenuRunner(this.parent, this.menu);

  Future enter() async {
    if (!entered) {
      entered = true;
      await parent?.enter();
      for (var enter in menu.enters) {
        await run(enter);
      }
    }
  }

  Future run(Runnable runnable) async {
    if (debugTestMenuManager) {
      write("[run] running '$runnable'");
    }
    try {
      await runnable.run();
    } catch (e, st) {
      if (e is TestFailure) {
        testMenuPresenter.write('ERROR CAUGHT $e');
      } else {
        testMenuPresenter.write('ERROR CAUGHT $e ${Trace.format(st)}');
      }
      rethrow;
    } finally {
      if (debugTestMenuManager) {
        write("[run] done '$runnable'");
      }
    }
  }

  Future leave() async {
    if (debugTestMenuManager) {
      write('[leave]  ${menu.leaves} $entered');
    }
    //devWrite('leave');
    if (entered) {
      entered = false;
      for (var leave in menu.leaves) {
        await run(leave);
      }
      _complete();
    }
  }
}
