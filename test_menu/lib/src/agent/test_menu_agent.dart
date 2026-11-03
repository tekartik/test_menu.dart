import 'package:dev_build/menu/menu_agent.dart';

import 'test_menu_agent_bridge_stub.dart'
    if (dart.library.js_interop) 'test_menu_agent_bridge_web.dart';

/// The global object of the web bridge, `window.tekartikAgent`, the one of
/// tekartik_app_agent: `commands()`, `run(name, args)` and `help()`.
const testMenuAgentBridgeName = 'tekartikAgent';

/// True when [uri] asks for the agent bridge: an `agent` query parameter
/// (`?agent`, any value).
bool testMenuAgentEnabled(Uri uri) => uri.queryParameters.containsKey('agent');

/// Lets an LLM agent drive the menu.
///
/// Registers the VM service extensions of the menu agent (skipped when an
/// app using tekartik_app_agent already registered its own). On the web,
/// when [uri] (the page url, `Uri.base` by default) has `?agent`, also
/// installs `window.tekartikAgent` ([testMenuAgentBridgeName]):
/// `commands()`, `run(name, args)` (a promise of `{ok: true, result}` or
/// `{ok: false, error}`, args an object or its json) and `help()`. An
/// existing bridge of an app is kept.
///
/// Returns true when the web bridge is installed.
bool testMenuAgentInit({Uri? uri}) {
  menuAgentVmRegister();
  if (!testMenuAgentEnabled(uri ?? Uri.base)) {
    return false;
  }
  return testMenuAgentBridgeInstall(menuAgent);
}
