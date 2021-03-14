import 'package:dev_test/package.dart';
import 'package:process_run/shell.dart';

Future main() async {
  await packageRunCi('.',
      options: PackageRunCiOptions(noAnalyze: true, noOverride: true));
  await Shell().run('dart analyze --fatal-warnings .');
}
