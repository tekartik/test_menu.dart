import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/pub_semver.dart';

Future<void> main() async {
  if (dartVersion >= Version(2, 12, 0, pre: '0')) {
    var shell = Shell();

    for (var dir in [
      'test_menu_io',
      'test_menu_browser',
      'test_menu',
      'test_menu_example',
    ]) {
      shell = shell.pushd(join('..', dir));
      await shell.run('''
    
    pub get
    dart tool/travis.dart
    
''');
      shell = shell.popd();
    }
  }
}
