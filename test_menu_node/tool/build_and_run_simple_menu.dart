import 'package:process_run/stdio.dart';
import 'package:tekartik_app_node_build/app_build.dart';

Future main() async {
  var builder = NodeAppBuilder(
    options: NodeAppOptions(srcFile: 'simple_menu.dart'),
  );
  await builder.compileAndRun(runOptions: NodeAppRunOptions(stdin: stdin));
}
