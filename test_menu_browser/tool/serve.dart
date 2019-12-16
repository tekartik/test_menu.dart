import 'dart:async';

import 'package:tekartik_build_utils/webdev/webdev.dart';

Future main() async {
  final port = 8080;
  print('Serving `web_dev` on http://localhost:$port');
  await serve([
    'web:$port',
    '--hot-reload',
    //'--live-reload',
    '--hostname',
    '0.0.0.0'
  ]);
}
