# LLM control of the menus (io, web, flutter): plan

Status (2026-11-03):

All four phases are done.

- Phase 1 (dev_build 1.2.0, dev_test.dart). Checked end to end with the
  `app-agent` MCP: `dart run <menu> --agent`, then `app_connect
  {vmService}`, then `menu_line` with a prompt and its answer.
- Phase 2: dev_build 1.2.0 is published.
- Phase 3 (tekartik_test_menu 0.8.1, test_menu_browser 0.9.3, this repo).
  Checked end to end with `webdev serve` (ddc), then `app_connect {open:
  <url>?agent}`, then `menu_line`: a sub menu, a prompt and its answer, a
  write. The Chrome test runs on dart2js and dart2wasm.
- Phase 4 (test_menu_flutter 1.2.0). Checked end to end: `flutter run -d
  linux`, then `app_connect {vmService}`; and a release web build opened
  with `?agent`. The same release moved the flutter console to the web
  console design (no window frame).
- An app and a menu in the same isolate: the first to register the VM
  extensions keeps them, the other one skips (no throw on either side since
  tekartik_app_agent 0.4.1). On the web, an app bridge already installed is
  kept.

The agent tests live in a new test package of the same repo,
`dev_test.dart/dev_build_test` (`tekartik_dev_build_test`, not published).
It uses the repo's dev_build through a path override. Its tests:

- in process, on the VM and in Chrome (js and wasm)
- `--agent` driven over the VM service, with a json-rpc client on a
  `dart:io` web socket
- a `menu_io.dart` script running in a browser

It is also the test bed for the phase 3 web bridge.

Two choices made in phase 1:

- The agent handles `-`, `.` and `?` itself.
- The io console echoes agent lines on stdout as if typed.

Goal: an LLM agent (Claude Code through the `app-agent` MCP server of
`tekartik_app_agent_mcp`) can read and drive any dev/test menu: the console
(io), the web console (test_menu_browser) and the flutter console
(test_menu_flutter). Constraints: small, no new package dependency (SDK
libraries only), no breaking change.

## 1. The wire contract to reuse

`tekartik_app_agent` already defines a JSON-only protocol, and the
`app-agent` MCP server already speaks it. The menu implements the same
contract without depending on `tekartik_app_agent`:

| Transport | Contract | SDK library |
| --- | --- | --- |
| VM service (io, flutter debug, DDC) | extension `ext.tekartik.agent.commands` returns `{commands: [{name, description, inputSchema}]}`; `ext.tekartik.agent.run` with params `name` and `args` (json text) returns `{ok: true, result}` or `{ok: false, error}` | `dart:developer`, `dart:convert` |
| Web page opened with `?agent` | `window.tekartikAgent` with `commands()`, `run(name, args)` (a promise of the same result) and `help()` | `dart:js_interop` |

The agent then does `app_connect` with one of these targets, and the menu
commands show up as tools:

- a VM service uri (`dart run --enable-vm-service`, `flutter run`)
- a url with `?agent`, opened in a headless Chrome
- a page of a Chrome started with `--remote-debugging-port`. webdev's
  launched Chrome is one, so the agent can drive the very tab the user sees.

## 2. Two commands are enough

- `menu`: the state.
  - `path`: menu names from the root.
  - `items`: `{key, name, kind: item | menu}`; `key` is the `cmd` or the
    index.
  - `canBack`.
  - `status`: `ready | running | input | error`.
  - `prompt`: the pending prompt text, or null.
  - `output`: the last `n` lines (argument `output`, default 20).
- `menu_line {line, timeout?}`: exactly what typing a line does, so all
  three UIs share one meaning. The line can be:
  - an item key or `cmd`
  - `-` or `.` to go back
  - `?` for help
  - the answer to a pending prompt
  - anything else, handed to the menu `command` handler

  It returns when the run ends or a prompt is waiting, or at `timeout`
  (default 30 s; the status then says `running`). The result holds the
  output written meanwhile (writes, `ERROR` lines, the prompt text, and the
  item's `print`s, captured by a zone) plus the new state.

Rules:

- A `menu_line` sent while a run is busy returns an error (`busy`, poll
  with `menu`). The human can still use the UI at the same time.
- Going back from the root is refused: the io console calls `exit(0)`
  there.

## 3. Where the code goes

### What each package holds today

| Package | Published | Holds |
| --- | --- | --- |
| `dev_build` (dev_test.dart) | yes, pub.dev | the whole core: `DevMenu`, `MenuManager`, `MenuPresenter`, the global `write`/`writeln`/`prompt`, the runner (`ERROR CAUGHT`), the io console (`_MenuManagerConsole`, private) |
| `tekartik_test_menu` | no (git) | typedefs only (`TestMenu = DevMenu`, `TestMenuManager = MenuManager`, ...) |
| `tekartik_test_menu_io` | no (git) | re-exports of dev_build's io console |
| `tekartik_test_menu_browser` | no (git) | web presenter, own `processLine` |
| `tekartik_test_menu_flutter` | no (git) | flutter presenter (`TestMenuConsole`), own `processLine` |

The menus run through two front ends:

- the test menus: io, browser and flutter
- the dev_build tool menus that skip test_menu (`package:dev_build/menu/menu_io.dart`)

Dozens of files across the tree use dev_build directly in the second way,
for example in firebase_tools.dart, app_build.dart and app_web_utils.dart.

### Can dev_build be left untouched?

Not for io. The io console class is private, and `MenuManager.processLine`
only knows numbers and `-`: no shortcuts, no prompt answer, no `command`
handler. So nothing outside dev_build can answer an io prompt or replay a
line the way the console does.

Capturing the output from outside would mean wrapping `menuPresenter`. That
breaks `menuPresenter as TestMenuManagerBrowser` in the existing tests and
apps. Keeping everything in `tekartik_test_menu` would also leave out the
dev_build-only tool menus, unless each one added a git dependency on
`tekartik_test_menu`.

### Recommendation: the platform agnostic core in dev_build, the web bridge in tekartik_test_menu

| Piece | Package | Size | Why there |
| --- | --- | --- | --- |
| Output and state hooks: a listener on the global `write`/`writeln`/`prompt` and the runner's error line, a running counter in `MenuManager.runItem`, the pending prompt | dev_build `src/menu` | ~40 lines | every write and prompt already goes through these functions |
| `MenuLineProcessor` (optional interface: `Future<void> processLine(String line)`), implemented by the io console | dev_build | ~10 lines | `MenuPresenter` stays unchanged (not breaking); the agent uses `menuPresenter is MenuLineProcessor`, else `MenuManager.processLine` |
| Agent commands `menu` and `menu_line` (json in, json out), zone `print` capture, busy and timeout handling | dev_build `src/menu/menu_agent.dart` | ~150 lines | one implementation for io, web, flutter and the tool menus |
| VM extensions (`registerExtension`, the names above, a second registration caught and skipped) | dev_build | ~30 lines | `dart:developer` works on every platform (VM, flutter, DDC) |
| io `--agent` flag: start the VM service (`Service.controlWebServer(enable: true)`), print its uri, stay alive when stdin closes (a background run) | dev_build io console | ~25 lines | the console's argument parser is there |
| Web bridge `window.tekartikAgent`, installed only when the url has `?agent` (`Uri.base`) | `tekartik_test_menu`, conditional import on `dart.library.js_interop` | ~50 lines | shared by the browser and the flutter web console; keeps js interop out of the published, io-oriented dev_build |
| `implements MenuLineProcessor` + bridge install in `initTestMenuBrowser` | test_menu_browser | ~5 lines | `processLine` exists |
| `implements MenuLineProcessor` (delegating to `console.processLine`) + bridge install in `initTestMenuFlutterConsole` | test_menu_flutter | ~10 lines | `processLine` exists |
| Nothing, docs only (`dart run --enable-vm-service` or `--agent`) | test_menu_io | 0 | it only re-exports dev_build |

No new dependency anywhere: `dart:developer`, `dart:convert`, `dart:async`
and `dart:js_interop` are SDK libraries, and test_menu_browser already
depends on `package:web`.

dev_build impact: minor, 1.1.17+3 to 1.2.0 (new API `MenuLineProcessor`,
the agent registration, the `--agent` flag; existing behavior unchanged).
CHANGELOG: `- Menus can be driven by an LLM agent: menu and menu_line
commands over the VM service (ext.tekartik.agent.*), --agent flag on the io
console`.

A smaller dev_build alternative, if the core should stay out of the
published package: dev_build only gets the hooks and `MenuLineProcessor`
(~50 lines, same minor bump). The commands and the VM extensions then go
to `tekartik_test_menu`. The cost: dev_build-only tool menus get nothing.

## 4. Phases

1. **dev_build**:
   - the hooks, `MenuLineProcessor` on the io console, `menu_agent.dart`
     and the VM registration.
   - the `--agent` flag.
   - unit tests of the json layer through a fake presenter: state, line,
     prompt answered by a second `menu_line`, timeout, busy, back refused
     at the root.
   - manual check: `dart run --enable-vm-service example/...` (or
     `--agent`), then `app_connect {vmService}` and the tools.
   - dev_build skill `dev-build-menu`.
2. **Publish dev_build 1.2.0** (Alex). The test_menu packages resolve
   dev_build from pub.dev (`test_menu.dart` has no dev_build override), so
   their CI can only use the new API after the release. Then raise their
   constraint to `dev_build: ">=1.2.0"`.
3. **tekartik_test_menu + test_menu_browser**:
   - the bridge.
   - a chrome test calling `window.tekartikAgent.run('menu_line', ...)`.
   - the skill `tekartik-test-menu-browser-setup`.
4. **test_menu_flutter**:
   - `MenuLineProcessor` and the web bridge.
   - a widget test of the json layer.
   - manual check: `flutter run` and `app_connect {vmService}`, plus a
     flutter web url with `?agent`.
   - the skill `tekartik-test-menu-flutter-setup`.

## 5. Open points

- **Same extension names as `tekartik_app_agent`.** An app that runs
  `agentInit` and a dev menu in the same isolate: the first to register
  keeps its commands, the other skips its registration (`agentInit` first
  keeps the app's). Should that case matter, the menu
  commands can be handed to the app's `AgentCommands` (same json shape, a
  few lines in the app), or use `ext.tekartik.menu.*` names that the MCP
  server also looks for (a change to `tekartik_app_agent_mcp`).
- **`Service.controlWebServer({enable, silenceOutput})`** is in the
  `dart:developer` of SDK 3.13.7 (checked). Still to try: whether it starts
  the service under `dart run` (JIT). In an AOT compiled executable there
  is no VM service, so `--agent` must say so.
- **No key for `?agent` on dev menus.** They are dev tools: unlike the
  release apps of `tekartik_app_agent`, a plain `?agent` is enough.
