import 'package:tekartik_test_menu_browser/key_value_universal.dart';
import 'package:tekartik_test_menu_browser/test_menu_universal.dart';

var myVar = 'MYVAR'.kvFromVar(defaultValue: '12345');
var myOtherVar = 'MYOTHERVAR'.kvFromVar();

void universalTestMenu() {
  menu('universal', () {
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
