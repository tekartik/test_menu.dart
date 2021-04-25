import 'package:tekartik_test_menu/test.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

Future main(List<String> args) async {
  mainMenu(args, () {
    // ignore: deprecated_member_use
    solo_menu('root test', () {
      test('test', () {
        expect(true, isFalse);
      });
    });
  });
}
