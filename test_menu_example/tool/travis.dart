import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
  
dartanalyzer --fatal-warnings --fatal-infos starter_browser starter_browser_mdl starter_io tool

''');
}
