import 'dart:async';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_deploy/gs_deploy.dart';
// ignore_for_file: non_constant_identifier_names

Future main(List<String> args) async {
//   pkg = new IoFsPubPackage(   await getPubPackageDir(new File(binScriptPath).parent));
  await grind(args);
}

@Task('Fs Deploy built app.')
Future fs_deploy_starter() async {
//...
  ProcessCmd cmd = ProcessCmd("fsdeploy",
      [join("build", "example", "starter_browser_mdl", "deploy.yaml")]);

  await runCmd(cmd);
}

@Task('build starter_browser_mdl')
void build_starter() {
  Pub.build(directories: [url.join('example', 'starter_browser_mdl')]);
}

Future gsDeploy(String ioInPath, String gsOut) async {
  ProcessCmd cmd = gsDeployCmd(ioInPath, gsOut);
  await runCmd(cmd);
}

@Task('Test deploy.')
Future gstestdeploy() async {
  await gsDeploy(join('build', 'example', 'deploy', 'starter_browser_mdl'),
      "gs://gstest.tekartik.com/test_menu");
}
