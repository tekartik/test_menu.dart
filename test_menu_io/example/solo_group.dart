import 'package:tekartik_test_menu_io/test_menu_io.dart';
import 'package:tekartik_test_menu/test.dart';

main(List<String> args) async {
  mainMenu(args, () {
    solo_group('root test', () {
      test('test', () {
        expect(true, isFalse);
      });
    });
  });
}
