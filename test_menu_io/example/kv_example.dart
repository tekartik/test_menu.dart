import 'package:tekartik_test_menu_io/key_value_io.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

//import '
var kv = 'MYVAR'.kvFromEnv(defaultValue: '12345');

Future main(List<String> arguments) async {
  mainMenu(arguments, () {
    item('set ${kv.key} VALUE1', () async {
      await kv.setToEnv('VALUE1');
      write(kv);
    });
    item('set ${kv.key} VALUE2', () async {
      await kv.setToEnv('VALUE2');
      write(kv);
    });
    item('delete ${kv.key}', () async {
      await kv.deleteFromEnv();
      write(kv);
    });
    item('dump ${kv.key}', () async {
      write(kv);
    });
  });
}
