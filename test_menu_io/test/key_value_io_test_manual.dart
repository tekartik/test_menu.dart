import 'package:tekartik_test_menu_io/key_value_io.dart';

var myVar = 'MYVAR'.kvFromEnv(defaultValue: '12345');

Future<void> main() async {
  for (var kv in [myVar]) {
    var newKv = await kv.promptToEnv();
    // ignore: avoid_print
    print(newKv);
  }
}
