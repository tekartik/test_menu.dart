@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_test_menu/test_menu_agent.dart';
import 'package:tekartik_test_menu_browser/test_menu_web.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

List<String> _texts(String selector) {
  final elements = document.querySelectorAll(selector);
  return [
    for (var i = 0; i < elements.length; i++) elements.item(i)!.textContent!,
  ];
}

String? _status() => document.querySelector('.tm-status')!.textContent;

JSObject get _bridge => globalContext[testMenuAgentBridgeName]! as JSObject;

/// `window.tekartikAgent.run(name, args)`, as the app-agent MCP server
/// calls it, [args] an object or its json.
Future<Map<String, Object?>> _run(String name, [Object? args]) async {
  final promise = _bridge.callMethod<JSPromise<JSAny?>>(
    'run'.toJS,
    name.toJS,
    args is String ? args.toJS : args?.jsify(),
  );
  // Through json, as the MCP server gets it.
  final value = jsonDecode(jsonEncode((await promise.toDart).dartify()));
  return (value as Map).cast<String, Object?>();
}

Future<Map<String, Object?>> _runOk(String name, [Object? args]) async {
  final value = await _run(name, args);
  expect(value['ok'], isTrue, reason: '$value');
  return (value['result'] as Map).cast<String, Object?>();
}

List<String> _items(Map<String, Object?> state) => [
  for (final item in (state['items'] as List).cast<Map>())
    '${item['key']} ${item['name']}${item['menu'] == true ? ' >' : ''}',
];

List<String> _output(Map<String, Object?> state) =>
    (state['output'] as List).cast<String>();

void main() {
  test('no bridge without ?agent', () async {
    await initTestMenuBrowser();
    expect(globalContext.has(testMenuAgentBridgeName), isFalse);
    expect(testMenuAgentInit(uri: Uri.parse('http://localhost/')), isFalse);
    expect(globalContext.has(testMenuAgentBridgeName), isFalse);
  });

  test('driven through window.tekartikAgent', () async {
    if (document.querySelector('.tm-root') == null) {
      await initTestMenuBrowser();
    }
    expect(
      testMenuAgentInit(uri: Uri.parse('http://localhost/?agent')),
      isTrue,
    );
    menu('main', () {
      item('write hi', () => write('hi'));
      item('ask', () async {
        write('got ${await prompt('Name?')}');
      });
      item('shortcut', () => write('short'), cmd: 's');
      command((line) => throw StateError('bad $line'));
    });
    await testMenuRun();

    final commands =
        _bridge.callMethod<JSAny?>('commands'.toJS).dartify()! as List;
    expect(
      [for (final command in commands) (command as Map)['name']],
      ['menu', 'menu_line'],
    );
    expect(
      (_bridge.callMethod<JSString>('help'.toJS)).toDart,
      contains('menu_line'),
    );

    var state = await _runOk('menu');
    expect(_items(state), ['0 main >']);
    expect(state['status'], 'ready');

    state = await _runOk('menu_line', {'line': '0'});
    expect(state['path'], ['main']);
    expect(_items(state), ['0 write hi', '1 ask', 's shortcut']);
    // The page follows.
    expect(_texts('.tm-crumb').skip(1), ['main']);

    state = await _runOk('menu_line', {'line': '0'});
    expect(_output(state), ['hi']);
    expect(_texts('.tm-log .tm-line').last, 'hi');

    // Args as json, a shortcut.
    state = await _runOk('menu_line', '{"line": "s"}');
    expect(_output(state), ['short']);

    // A prompt, answered by the next line, on the page too.
    state = await _runOk('menu_line', {'line': '1'});
    expect(state['status'], 'input');
    expect(state['prompt'], 'Name?');
    expect(_output(state), ['PROMPT Name?']);
    expect(_status(), 'INPUT');
    state = await _runOk('menu_line', {'line': 'Alex'});
    expect(state['status'], 'ready');
    expect(_output(state), ['ANSWER Alex', 'got Alex']);
    expect(_texts('.tm-prompt-answer'), ['Alex']);
    expect(_status(), 'READY');

    // The command handler, its error recorded once, without the console
    // logs.
    state = await _runOk('menu_line', {'line': 'boom'});
    final output = _output(state);
    expect(output, hasLength(1));
    expect(output.single, startsWith('ERROR Bad state: bad boom'));
    expect(_texts('.tm-line-error').last, contains('bad boom'));

    state = await _runOk('menu_line', {'line': '-'});
    expect(state['path'], isEmpty);
    expect(_texts('.tm-crumb'), hasLength(1));

    final error = await _run('menu_line', {'line': '-'});
    expect(error['ok'], isFalse);
    expect(error['error'], contains('top menu'));
  });
}
