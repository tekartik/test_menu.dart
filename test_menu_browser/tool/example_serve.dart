import 'dart:async';
import 'dart:io';

import 'package:process_run/shell_run.dart';

Future main() async {
  stdout.writeln('Serving `web_dev` on http://localhost:8060');
  await run('webdev serve example:8060 --live-reload --hostname 0.0.0.0');
}
