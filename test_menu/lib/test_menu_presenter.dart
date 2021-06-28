// public export of the test item to allow for a given presenter

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart';

// What to implement
abstract class TestMenuPresenter {
  // show the menu
  void presentMenu(TestMenu menu);

  // prompt
  Future<String?>? prompt(Object? message);

  // write the console
  void write(Object message);

  Future preProcessItem(TestItem item);

  Future preProcessMenu(TestMenu menu);
}

abstract class TestMenuPresenterMixin implements TestMenuPresenter {
  @override
  Future preProcessItem(TestItem item) async {}

  @override
  Future preProcessMenu(TestMenu menu) async {}
}

class _NullTestMenuPresenter extends Object
    with TestMenuPresenterMixin
    implements TestMenuPresenter {
  @override
  void presentMenu(TestMenu menu) {}

  @override
  Future<String>? prompt(Object? message) {
    return null;
  }

  @override
  void write(Object message) {}
}

class NullTestMenuPresenter extends _NullTestMenuPresenter {
  NullTestMenuPresenter() {
    // set as presenter
    testMenuPresenter = this;
    testMenuManager = null;
  }
}

NullTestMenuPresenter nullTestMenuPresenter = NullTestMenuPresenter();
TestMenuPresenter? _testMenuPresenter;

TestMenuPresenter get testMenuPresenter =>
    _testMenuPresenter ?? nullTestMenuPresenter;

set testMenuPresenter(TestMenuPresenter testMenuPresenter) =>
    _testMenuPresenter = testMenuPresenter;
