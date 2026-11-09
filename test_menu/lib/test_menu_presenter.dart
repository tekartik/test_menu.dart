/// [TestMenuPresenter]: shows the menu and its output somewhere else (a
/// widget, a log), set with [testMenuPresenter].
library;

import 'package:tekartik_test_menu/test_menu_presenter.dart';

export 'package:dev_build/src/menu/presenter_mixin.dart';

/// Test menu presenter.
typedef TestMenuPresenter = MenuPresenter;

/// Test menu presenter mixin.
typedef TestMenuPresenterMixin = MenuPresenterMixin;

/// Set the global menu presenter.
set testMenuPresenter(MenuPresenter value) {
  menuPresenter = value;
}
