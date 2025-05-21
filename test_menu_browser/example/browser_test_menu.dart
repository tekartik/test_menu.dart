import 'package:tekartik_test_menu/test_menu.dart';
import 'package:tekartik_test_menu_browser/key_value_browser.dart';

var myVar = 'MYVAR'.kvFromLocalStorage(defaultValue: '12345');
var myOtherVar = 'MYOTHERVAR'.kvFromLocalStorage();

void browserTestMenu() {
  menu('browser', () {
    keyValuesMenu('vars', [myVar, myOtherVar]);
    keyValuesMenu('vars2', [
      myVar,
      myOtherVar,
      myVar,
      myOtherVar,
      myVar,
      myOtherVar,
    ]);
  });
}
