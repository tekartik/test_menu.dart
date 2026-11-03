import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dev_build/menu/menu_agent.dart';

import 'test_menu_agent.dart';

const _help =
    'The commands of this test menu. $testMenuAgentBridgeName.commands(): '
    'their descriptions (name, description, inputSchema). '
    '$testMenuAgentBridgeName.run(name, args): a promise of {ok: true, '
    'result} or {ok: false, error}, args an object (or its json). menu: the '
    'state and output, menu_line {line}: a line typed in the menu.';

var _installed = false;

/// Installs `window.tekartikAgent` running the commands of [agent], unless
/// another bridge (an app using tekartik_app_agent) is there.
bool testMenuAgentBridgeInstall(MenuAgent agent) {
  if (!_installed && globalContext.has(testMenuAgentBridgeName)) {
    return false;
  }
  final bridge = JSObject();
  bridge['commands'] = (() => agent.describe().jsify()).toJS;
  bridge['run'] = ((JSString name, [JSAny? args]) {
    return (() async {
      Map<String, Object?>? map;
      var dartArgs = args?.dartify();
      if (dartArgs is String && dartArgs.isNotEmpty) {
        dartArgs = jsonDecode(dartArgs);
      }
      if (dartArgs is Map) {
        map = dartArgs.cast<String, Object?>();
      }
      return (await agent.run(name.toDart, map)).jsify();
    })().toJS;
  }).toJS;
  bridge['help'] = (() => _help.toJS).toJS;
  globalContext[testMenuAgentBridgeName] = bridge;
  _installed = true;
  return true;
}
