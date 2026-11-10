import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// The arguments of the node command line (`process.argv` after the node
/// executable and the script), null when not running on node.
///
/// dart2js calls `main` with an empty list on node.
List<String>? get nodeProcessArguments {
  final process = globalContext['process'];
  if (process == null || !process.isA<JSObject>()) {
    return null;
  }
  final argv = (process as JSObject)['argv'];
  if (argv == null || !argv.isA<JSArray>()) {
    return null;
  }
  return (argv as JSArray<JSString>).toDart
      .skip(2)
      .map((argument) => argument.toDart)
      .toList();
}
