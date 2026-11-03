/// Lets an LLM agent read and drive a test menu: the `menu` and `menu_line`
/// commands of the dev_build menu agent, over the VM service and, on the
/// web, through `window.tekartikAgent` when the page url has `?agent`
/// ([testMenuAgentInit]).
///
/// The `app-agent` MCP server (tekartik_app_agent_mcp) drives both:
/// `app_connect` with the VM service uri, or with the page url.
library;

export 'package:dev_build/menu/menu_agent.dart';

export 'src/agent/test_menu_agent.dart'
    show testMenuAgentInit, testMenuAgentEnabled, testMenuAgentBridgeName;
