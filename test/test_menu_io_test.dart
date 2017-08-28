@TestOn("vm")
library test_menu_test;

import 'package:tekartik_test_menu/test_menu_io.dart';
import 'package:test/test.dart';

main() {
  group('io', () {
    test('solo', () async {
      int a;
      int b;
      int c;
      //testMenuNewDeclarer();
      menu('main', () {
        // ignore: deprecated_member_use
        solo_item("1", () async {
          a = 1;
        });
        item("2", () {
          b = 2;
        });
        menu('sub', () {
          // ignore: deprecated_member_use
          solo_item("3", () {
            c = 3;
          });
        });
      });
      await testMenuRun();
      expect(a, 1);
      expect(b, isNull);
      expect(c, 3);
    });
  });
}
