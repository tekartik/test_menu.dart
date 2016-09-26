import 'package:grinder/grinder.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_deploy/gs_deploy.dart';
//import 'package:tekartik_pub/pub_fs_io.dart';

//import 'package:tekartik_pub/script.dart';


main(args) async {
//   pkg = new IoFsPubPackage(   await getPubPackageDir(new File(binScriptPath).parent));
  await grind(args);
}

/*
class BinScript extends Script {}

String get binScriptPath => getScriptPath(BinScript);
IoFsPubPackage pkg;

Future<ProcessResult> runCmd(ProcessCmd cmd) {
  print(cmd);
  return process.runCmd(cmd
    ..connectStderr = true
    ..connectStdout = true);
}

@DefaultTask('Build the project.')
build() async {
  log("Building...");
  //new PubApp.local('build').([]);
  await pkg.runPub(pubBuildArgs(args: ['web']),
      connectStdout: true, connectStderr: true);
}

@Task('Test stuff.')
@Depends(build)
test() {
  new PubApp.local('test').run([]);
}

@Task('Generate docs.')
doc() {
  log("Generating docs...");
}

@Task('Deploy built app.')
@Depends(build, test, doc)
deploy() {
//...
}
*/
@Task('Fs Deploy built app.')
fs_deploy_starter() async {
//...
  ProcessCmd cmd = processCmd(
      "fsdeploy", [join("build", "example", "starter_browser_mdl", "deploy.yaml")]);

  await runCmd(cmd);
}

/*
gsDeploy(String gsOut) async {
  String webDirPath = join(pkg.dir.path, 'build', 'deploy', 'web');
  ProcessCmd cmd = gsDeployCmd(webDirPath, gsOut);
  await runCmd(cmd);
}

@Task('Test deploy.')
@Depends(fsdeploy)
gstestdeploy() async {
  await gsDeploy("gs://gstest.tekartik.com/tradhiv2016");
}

// gsutil defacl ch -u AllUsers:R gs://event.festenao.com

@Task('Prod deploy.')
@Depends(fsdeploy)
gsproddeploy() async {
  await gsDeploy("gs://event.festenao.com/tradhiv2016");
}

@Task('prod')
@Depends(build, fsdeploy, gsproddeploy)
gsprod() {}

@Task('test')
@Depends(build, fsdeploy, gstestdeploy)
gstest() {}
*/

@Task('build starter_browser_mdl')
build_starter() {
  Pub.build(directories: [url.join('example', 'starter_browser_mdl')]);
}

gsDeploy(String ioInPath, String gsOut) async {
  ProcessCmd cmd = gsDeployCmd(ioInPath, gsOut);
  await runCmd(cmd);
}

@Task('Test deploy.')
gstestdeploy() async {
  await gsDeploy(join('build', 'example', 'deploy', 'starter_browser_mdl'),
      "gs://gstest.tekartik.com/test_menu");
}
