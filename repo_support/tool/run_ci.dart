import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  for (var dir in [
    'test_menu_io',
    'test_menu_browser',
    'test_menu',
    'test_menu_example',
  ]) {
    await packageRunCi(join('..', dir));
  }
}
