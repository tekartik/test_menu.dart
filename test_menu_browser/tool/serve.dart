import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';

Future main() async {
  final port = 8080;
  stdout.writeln('Serving `web_dev` on http://localhost:$port');
  await run(
    'dart pub global run webdev serve web:$port --hot-reload --hostname 0.0.0.0',
  );
}
