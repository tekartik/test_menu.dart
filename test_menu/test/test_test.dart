library test_menu_test;

import 'package:dev_test/test.dart';
import 'package:tekartik_test_menu/test.dart' as common_test;
import 'package:tekartik_test_menu/test_menu.dart' as common_test;

void main() {
  group('test', () {
    //TestMenuManager.debug.on
    test('auto_run', () async {
      var ran = false;

      common_test.group('group', () {
        // ignore: deprecated_member_use, deprecated_member_use_from_same_package
        common_test.solo_test('test', () {
          ran = true;
        });
      });

      await common_test.testMenuRun();
      expect(ran, isTrue);
    });
  });

  group('expect', () {
    //TestMenuManager.debug.on
    test('fail', () async {
      var ran = false;

      common_test.group('group', () {
        // ignore: deprecated_member_use, deprecated_member_use_from_same_package
        common_test.solo_test('test', () {
          ran = true;
          //_.expect(true, isFalse);
        });
      });

      await common_test.testMenuRun();
      expect(ran, isTrue);
    });

    test('success', () async {
      var ran = false;

      common_test.group('group', () {
        // ignore: deprecated_member_use, deprecated_member_use_from_same_package
        common_test.solo_test('test', () {
          common_test.expect(true, isTrue);
          ran = true;
        });
      });

      await common_test.testMenuRun();
      expect(ran, isTrue);
    });
  });
}
