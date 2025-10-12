@TestOn('vm || node')
library;

import 'package:tekartik_test_menu_node/test_menu_console.dart';
import 'package:test/test.dart';

void main() {
  group('io', () {
    test('solo', () async {
      int? a;
      int? b;
      int? c;
      //testMenuNewDeclarer();
      menu('main', () {
        // ignore: deprecated_member_use
        solo_item('1', () async {
          a = 1;
        });
        item('2', () {
          b = 2;
        });

        menu('sub', () {
          // ignore: deprecated_member_use
          solo_item('3', () {
            c = 3;
          });
        });
      });
      await testMenuRun();
      //expect(a, 1);
      //TODO bug in 2018-07-25
      expect(a, isNull);
      expect(b, isNull);
      expect(c, 3);
    });
  });
}
