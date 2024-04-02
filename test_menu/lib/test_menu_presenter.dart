import 'package:tekartik_test_menu/test_menu_presenter.dart';

export 'package:dev_build/src/menu/presenter_mixin.dart';

typedef TestMenuPresenter = MenuPresenter;
typedef TestMenuPresenterMixin = MenuPresenterMixin;

set testMenuPresenter(MenuPresenter value) {
  menuPresenter = value;
}
