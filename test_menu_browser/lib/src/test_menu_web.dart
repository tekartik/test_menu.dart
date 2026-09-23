library;

import 'dart:js_interop' hide JSAnyOperatorExtension;
import 'dart:js_interop_unsafe';

import 'package:tekartik_browser_utils/location_info_utils.dart';
import 'package:tekartik_prefs_browser/prefs_light.dart';
import 'package:tekartik_test_menu/src/test_menu/test_menu.dart'; // ignore: implementation_imports
import 'package:tekartik_test_menu/src/test_menu/test_menu_manager.dart'; // ignore: implementation_imports
import 'package:tekartik_test_menu/test_menu_presenter.dart';
import 'package:tekartik_test_menu_browser/src/common_browser.dart';
import 'package:tekartik_test_menu_browser/src/import.dart';
import 'package:tekartik_test_menu_browser/src/web/test_menu_web_icons.dart';
import 'package:tekartik_test_menu_browser/src/web/test_menu_web_style.dart';
import 'package:web/web.dart';

export 'package:tekartik_test_menu/test_menu.dart';
export 'package:tekartik_test_menu_browser/src/common_browser.dart';

void _log(Object message) {
  // ignore: avoid_print
  print('/tmw $message');
}

// var debugTestMenuWeb = devWarning(true);
const debugTestMenuWeb = false;
@Deprecated('Use testMenuBrowserContainerId')
// ignore: constant_identifier_names
const String CONTAINER_ID = testMenuBrowserContainerId;
const String testMenuBrowserContainerId = 'tekartik_test_menu_container';

/// Output entries kept on screen.
const _maxOutputCount = 100;

/// Recently run items offered as quick chips.
const _maxRecentCount = 8;

/// Items offered on the keypad.
const _maxKeyCount = 10;

const _maxHistoryCount = 50;
const _styleElementId = 'tekartik_test_menu_style';

/// Local storage entries are prefixed by `tekartik_test_menu/`.
const _prefsName = 'tekartik_test_menu';
const _prefsThemeKey = 'theme';
const _prefsMenuKey = 'menu';

/// Menu height limit, in percent of the output and menu area, bounded by a
/// min and max in pixels. It only applies when the menu is below the output
/// (narrow screens).
const _menuPercentDefault = 40;
const _menuMinDefault = 120;
const _menuMaxDefault = 480;

const _exitCommands = {'-', '.'};
const _helpCommand = '?';

void jsTest(String name) {
  globalContext.callMethod(name.toJS);
}

T _withClass<T extends Element>(T element, String className, [String? text]) {
  element.className = className;
  if (text != null) {
    element.textContent = text;
  }
  return element;
}

HTMLButtonElement _button(String className, {String? text, String? label}) {
  final button = _withClass(HTMLButtonElement(), className, text)
    ..type = 'button';
  if (label != null) {
    button
      ..title = label
      ..setAttribute('aria-label', label);
  }
  return button;
}

HTMLButtonElement _iconButton(String className, String icon, String label) =>
    _button(className, label: label)..appendChild(svgIcon(icon));

void _setLabel(Element element, String label) {
  element
    ..setAttribute('title', label)
    ..setAttribute('aria-label', label);
}

/// Built from char codes, ddc emits non ascii characters as is and a page
/// without `<meta charset="utf-8">` would display `â€º`.
final _pathSeparator = ' ${String.fromCharCode(0x203a)} ';
final _arrowsUpDown = String.fromCharCodes([0x2191, 0x2193]);

// can be extended
class TestMenuManagerBrowser extends TestMenuPresenter
    with TestMenuPresenterMixin {
  TestMenu? displayedMenu;
  var _displayedDepth = -1;

  /// The root element, found by [testMenuBrowserContainerId] or appended to
  /// the body.
  Element? container;

  /// The menu section.
  Element? menuContainer;

  /// The output log.
  Element? output;

  /// The command line, also used to answer prompts.
  HTMLInputElement? basicInput;

  var outBuffer = OutBuffer(_maxOutputCount);

  late HTMLElement _scroller;
  late HTMLElement _outputSection;
  late HTMLElement _status;
  late HTMLElement _crumbPath;
  late HTMLElement _crumbMeta;
  late HTMLElement _quick;
  late HTMLElement _keys;
  late HTMLButtonElement _themeButton;
  late HTMLElement _frame;
  late HTMLButtonElement _menuButton;
  late HTMLButtonElement _settingsButton;
  late HTMLElement _settings;
  late HTMLInputElement _menuShowInput;
  late HTMLInputElement _menuLimitInput;

  /// Percent, min and max inputs.
  late List<HTMLInputElement> _menuSizeInputs;

  /// Theme and menu layout storage, local storage by default.
  final PrefsLight prefs;

  // Menu layout, saved in [prefs].
  var _menuHidden = false;
  var _menuLimit = true;
  var _menuPercent = _menuPercentDefault;
  var _menuMin = _menuMinDefault;
  var _menuMax = _menuMaxDefault;

  /// Output entry of the pending prompt.
  HTMLElement? _promptEntry;

  final _recents = <TestItem>[];
  final _history = <String>[];
  int? _historyIndex;
  var _historyDraft = '';

  final _running = <TestItem>{};
  final _itemButtons = <TestItem, Element>{};
  var _runningCount = 0;
  var _lastRunFailed = false;

  void commonLog(Object message) {
    _log('[w] $message');
  }

  @override
  void write(Object message) {
    writeln(message);
  }

  @override
  void writeln(Object message) {
    final text = '$message';
    outBuffer.add(text);
    if (debugTestMenuManager) {
      _log('[bwsr writ] $text');
    }
    commonLog(text);
    if (text.startsWith('ERROR')) {
      _appendError(text);
    } else {
      _append(_line('', text));
    }
  }

  Completer<String>? promptCompleter;

  @override
  Future<String> prompt(Object? message) async {
    findContainer();
    final text = '${message ?? 'Enter text'}';
    outBuffer.add('[PROMPT]: $text');
    commonLog('[PROMPT]: $text');

    _promptEntry?.removeAttribute('data-waiting');
    final entry = _line('tm-line-prompt')
      ..setAttribute('data-waiting', '')
      ..appendChild(_withClass(HTMLSpanElement(), 'tm-prompt-label', 'PROMPT '))
      ..appendChild(HTMLSpanElement()..textContent = text);
    _append(entry, follow: true);
    _promptEntry = entry;

    var completer = Completer<String>.sync();
    promptCompleter = completer;
    if (debugTestMenuWeb) {
      _log('promptCompleter ${promptCompleter.hashCode}');
    }
    container!.setAttribute('data-prompting', '');
    basicInput!
      ..placeholder = text
      ..focus();
    _updateStatus();

    var result = await completer.future;
    if (debugTestMenuWeb) {
      _log('Prompt result $result');
    }
    return result;
  }

  void _answerPrompt(String value) {
    final completer = promptCompleter!;
    promptCompleter = null;
    if (debugTestMenuWeb) {
      _log('answer: $value ${completer.hashCode} ${completer.isCompleted}');
    }
    final entry = _promptEntry;
    _promptEntry = null;
    if (entry != null) {
      entry
        ..removeAttribute('data-waiting')
        ..appendChild(
          _withClass(
            HTMLSpanElement(),
            'tm-prompt-answer',
            value.isEmpty ? '(empty)' : value,
          ),
        );
    }
    container!.removeAttribute('data-prompting');
    basicInput!.placeholder = _commandPlaceholder;
    _updateStatus();
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  /// [prefs] default to the browser local storage.
  TestMenuManagerBrowser({PrefsLight? prefs})
    : prefs =
          prefs ??
          getPrefsLightBrowserOrNull(name: _prefsName) ??
          PrefsMemory() {
    if (locationInfo!.arguments.containsKey('debug')) {
      // ignore: deprecated_member_use
      TestMenuManager.debug.on = true;
    }
  }

  static const _commandPlaceholder = 'Item # or command (? help)';

  /// Build the console in the container (created if needed), once.
  void findContainer() {
    if (container != null) {
      return;
    }
    _injectStyle();
    var root = document.getElementById(testMenuBrowserContainerId);
    if (root == null) {
      root = HTMLDivElement()..id = testMenuBrowserContainerId;
      document.body!.appendChild(root);
    }
    document.body?.classList.add('tm-page');
    root.classList.add('tm-root');
    container = root;

    final frame = _frame = _withClass(HTMLDivElement(), 'tm-window');

    // Title bar
    final dots = _withClass(HTMLSpanElement(), 'tm-dots')
      ..setAttribute('aria-hidden', 'true');
    for (var i = 0; i < 3; i++) {
      dots.appendChild(HTMLSpanElement());
    }
    final title = document.title.trim();
    _status = _withClass(HTMLSpanElement(), 'tm-status')
      ..setAttribute('role', 'status');
    _themeButton = _button('tm-icon-btn')
      ..onClick.listen((_) => _toggleTheme());
    _menuButton = _iconButton('tm-icon-btn', iconMenu, 'Hide menu')
      ..onClick.listen((_) {
        _menuHidden = !_menuHidden;
        _menuLayoutChanged();
      });
    _settingsButton = _iconButton('tm-icon-btn', iconSettings, 'Menu layout')
      ..setAttribute('aria-expanded', 'false')
      ..onClick.listen((_) => _toggleSettings());
    final titleBar = _withClass(HTMLElement.header(), 'tm-titlebar')
      ..appendChild(dots)
      ..appendChild(
        _withClass(
          HTMLSpanElement(),
          'tm-title',
          title.isEmpty ? 'test menu' : title,
        ),
      )
      ..appendChild(_status)
      ..appendChild(_withClass(HTMLSpanElement(), 'tm-spacer'))
      ..appendChild(_menuButton)
      ..appendChild(_settingsButton)
      ..appendChild(
        _iconButton('tm-icon-btn', iconTrash, 'Clear output')
          ..onClick.listen((_) => clearOutput()),
      )
      ..appendChild(_themeButton);

    // Breadcrumb and recent items
    _crumbPath = _withClass(HTMLSpanElement(), 'tm-crumb-path');
    _crumbMeta = _withClass(HTMLSpanElement(), 'tm-crumb-meta')
      ..title = 'Reloading the page runs this item again';
    final crumbs = _withClass(HTMLElement.nav(), 'tm-crumbs')
      ..setAttribute('aria-label', 'Menu path')
      ..appendChild(_crumbPath)
      ..appendChild(_crumbMeta);
    _quick = _withClass(HTMLDivElement(), 'tm-quick')
      ..setAttribute('hidden', '');

    // Output and menu
    output = _withClass(HTMLDivElement(), 'tm-log')
      ..setAttribute('role', 'log');
    _outputSection = _withClass(HTMLElement.section(), 'tm-output')
      ..setAttribute('aria-label', 'Output')
      ..appendChild(output!);
    menuContainer = _withClass(HTMLElement.section(), 'tm-menu')
      ..setAttribute('aria-label', 'Menu');
    _scroller = _withClass(HTMLDivElement(), 'tm-main')
      ..appendChild(_outputSection)
      ..appendChild(menuContainer!);

    // Keypad and command line
    // Item keys scroll, history keys stay on the right.
    _keys = _withClass(HTMLDivElement(), 'tm-keys-items');
    void history(int delta) {
      _historyMove(delta);
      basicInput!.focus();
    }

    final keyRow = _withClass(HTMLDivElement(), 'tm-keys')
      ..appendChild(_keys)
      ..appendChild(
        _iconButton('tm-key', iconUp, 'Previous command')
          ..onClick.listen((_) => history(-1)),
      )
      ..appendChild(
        _iconButton('tm-key', iconDown, 'Next command')
          ..onClick.listen((_) => history(1)),
      );
    basicInput = _withClass(HTMLInputElement(), 'tm-input')
      ..type = 'text'
      ..autocomplete = 'off'
      ..spellcheck = false
      ..placeholder = _commandPlaceholder
      ..setAttribute('aria-label', 'Command')
      ..setAttribute('autocapitalize', 'off');
    basicInput!.onKeyDown.listen(_onInputKeyDown);
    final form = _withClass(HTMLFormElement(), 'tm-command')
      ..appendChild(
        _withClass(HTMLSpanElement(), 'tm-command-caret', '>')
          ..setAttribute('aria-hidden', 'true'),
      )
      ..appendChild(basicInput!)
      ..appendChild(_iconButton('tm-send', iconSend, 'Run')..type = 'submit');
    form.onSubmit.listen((event) {
      event.preventDefault();
      final input = basicInput!;
      final line = input.value;
      input.value = '';
      _historyIndex = null;
      processLine(line);
    });
    final footer = _withClass(HTMLElement.footer(), 'tm-footer')
      ..appendChild(keyRow)
      ..appendChild(form);

    _settings = _buildSettings();
    frame
      ..appendChild(titleBar)
      ..appendChild(_settings)
      ..appendChild(crumbs)
      ..appendChild(_quick)
      ..appendChild(_scroller)
      ..appendChild(footer);
    root.appendChild(frame);

    _updateThemeButton();
    _applyMenuLayout();
    _updateStatus();
    window.onKeyDown.listen(_onDocumentKeyDown);
    // Only grab the focus when it does not pop up a virtual keyboard.
    if (window.matchMedia('(pointer: fine)').matches) {
      basicInput!.focus();
    }
    final charset = document.characterSet;
    if (charset.toUpperCase() != 'UTF-8') {
      _log(
        'page charset is $charset, add <meta charset="utf-8"> to the html '
        'head if non ascii characters are not displayed correctly',
      );
    }
    unawaited(_loadPrefs());
  }

  HTMLElement _buildSettings() {
    _menuShowInput = _checkbox(() {
      _menuHidden = !_menuShowInput.checked;
      _menuLayoutChanged();
    });
    _menuLimitInput = _checkbox(() {
      _menuLimit = _menuLimitInput.checked;
      _menuLayoutChanged();
    });
    _menuSizeInputs = [
      _numberInput(min: 5, max: 100, step: 5, onValue: (v) => _menuPercent = v),
      _numberInput(min: 0, max: 10000, step: 10, onValue: (v) => _menuMin = v),
      _numberInput(min: 0, max: 10000, step: 10, onValue: (v) => _menuMax = v),
    ];
    final [percent, minHeight, maxHeight] = _menuSizeInputs;
    return _withClass(HTMLDivElement(), 'tm-settings')
      ..setAttribute('hidden', '')
      ..setAttribute('role', 'group')
      ..setAttribute('aria-label', 'Menu layout')
      ..appendChild(_withClass(HTMLSpanElement(), 'tm-settings-label', 'MENU'))
      ..appendChild(_field([_menuShowInput, 'show']))
      ..appendChild(_field([_menuLimitInput, 'limit height to']))
      ..appendChild(_field([percent, '% of height']))
      ..appendChild(_field(['min', minHeight, 'px']))
      ..appendChild(_field(['max', maxHeight, 'px']))
      ..appendChild(
        _button(
          'tm-chip tm-settings-reset',
          text: 'reset',
          label: 'Reset the menu layout',
        )..onClick.listen((_) => _resetMenuLayout()),
      )
      ..appendChild(
        _withClass(
          HTMLSpanElement(),
          'tm-settings-hint',
          'The height limit applies when the menu is below the output',
        ),
      );
  }

  /// A label wrapping [parts], texts or elements.
  HTMLLabelElement _field(List<Object> parts) {
    final label = _withClass(HTMLLabelElement(), 'tm-field');
    for (final part in parts) {
      label.appendChild(part is String ? Text(part) : part as Element);
    }
    return label;
  }

  HTMLInputElement _checkbox(void Function() onChange) {
    final input = HTMLInputElement()..type = 'checkbox';
    input.onChange.listen((_) => onChange());
    return input;
  }

  HTMLInputElement _numberInput({
    required int min,
    required int max,
    required int step,
    required void Function(int value) onValue,
  }) {
    final input = _withClass(HTMLInputElement(), 'tm-num')
      ..type = 'number'
      ..min = '$min'
      ..max = '$max'
      ..step = '$step'
      ..setAttribute('inputmode', 'numeric');
    // Applied while typing, invalid values are ignored.
    input.onInput.listen((_) {
      final value = int.tryParse(input.value.trim());
      if (value != null && value >= min && value <= max) {
        onValue(value);
        _menuLayoutChanged(syncInputs: false);
      }
    });
    // Show back the value in use once done.
    input.onChange.listen((_) => _syncMenuSizeInputs());
    return input;
  }

  void _toggleSettings() {
    final open = _settings.hasAttribute('hidden');
    _settings.toggleAttribute('hidden', !open);
    _settingsButton.setAttribute('aria-expanded', '$open');
  }

  void _applyMenuLayout({bool syncInputs = true}) {
    _frame
      ..toggleAttribute('data-menu-hidden', _menuHidden)
      ..toggleAttribute('data-menu-limit', _menuLimit);
    _frame.style
      ..setProperty('--tm-menu-percent', '$_menuPercent%')
      ..setProperty('--tm-menu-min', '${_menuMin}px')
      ..setProperty('--tm-menu-max', '${_menuMax}px');
    _menuButton.setAttribute('aria-pressed', '${!_menuHidden}');
    _setLabel(_menuButton, _menuHidden ? 'Show menu' : 'Hide menu');
    _menuShowInput.checked = !_menuHidden;
    _menuLimitInput
      ..checked = _menuLimit
      ..disabled = _menuHidden;
    for (final input in _menuSizeInputs) {
      input.disabled = _menuHidden || !_menuLimit;
    }
    if (syncInputs) {
      _syncMenuSizeInputs();
    }
  }

  void _syncMenuSizeInputs() {
    final values = [_menuPercent, _menuMin, _menuMax];
    for (var i = 0; i < values.length; i++) {
      _menuSizeInputs[i].value = '${values[i]}';
    }
  }

  void _menuLayoutChanged({bool syncInputs = true}) {
    _applyMenuLayout(syncInputs: syncInputs);
    _savePrefs(
      () => prefs.setMap(_prefsMenuKey, {
        'hidden': _menuHidden,
        'limit': _menuLimit,
        'percent': _menuPercent,
        'min': _menuMin,
        'max': _menuMax,
      }),
    );
  }

  void _resetMenuLayout() {
    _menuHidden = false;
    _menuLimit = true;
    _menuPercent = _menuPercentDefault;
    _menuMin = _menuMinDefault;
    _menuMax = _menuMaxDefault;
    _applyMenuLayout();
    _savePrefs(() => prefs.remove(_prefsMenuKey));
  }

  Future<void> _loadPrefs() async {
    try {
      final theme = await prefs.getString(_prefsThemeKey);
      if (theme == 'light' || theme == 'dark') {
        container!.setAttribute('data-theme', theme!);
        _updateThemeButton();
      }
      final menu = await prefs.getMap(_prefsMenuKey);
      if (menu != null) {
        int intValue(String key, int defaultValue, int min, int max) {
          final value = menu[key];
          return value is int && value >= min && value <= max
              ? value
              : defaultValue;
        }

        _menuHidden = menu['hidden'] == true;
        _menuLimit = menu['limit'] != false;
        _menuPercent = intValue('percent', _menuPercentDefault, 5, 100);
        _menuMin = intValue('min', _menuMinDefault, 0, 10000);
        _menuMax = intValue('max', _menuMaxDefault, 0, 10000);
        _applyMenuLayout();
      }
    } catch (e) {
      _log('prefs error $e');
    }
  }

  void _savePrefs(Future<void> Function() action) {
    unawaited(
      action().catchError((Object e) {
        _log('prefs error $e');
      }),
    );
  }

  void _injectStyle() {
    if (document.getElementById(_styleElementId) != null) {
      return;
    }
    final style = HTMLStyleElement()
      ..id = _styleElementId
      ..textContent = testMenuWebCss;
    // First in head so that the page styles can override it.
    final head = document.head!;
    head.insertBefore(style, head.firstChild);
  }

  /// Clear the output.
  void clearOutput() {
    findContainer();
    outBuffer.lines.clear();
    final log = output!;
    log.textContent = '';
    // A pending prompt must stay visible.
    final promptEntry = _promptEntry;
    if (promptEntry != null) {
      log.appendChild(promptEntry);
    }
  }

  HTMLElement _line(String className, [String? text]) =>
      _withClass(HTMLDivElement(), 'tm-line $className', text);

  void _info(String text) => _append(_line('tm-line-info', text), follow: true);

  /// Last error entry and its text, see [_fixLastError].
  (Element, String)? _lastError;

  void _appendError(String text) {
    final entry = _line('tm-line-error');
    final newline = text.indexOf('\n');
    if (newline < 0) {
      _fillError(entry, text, null);
    } else {
      _fillError(
        entry,
        text.substring(0, newline),
        text.substring(newline + 1),
      );
    }
    _lastError = (entry, text);
    _append(entry);
  }

  void _fillError(Element entry, String summary, String? stackTrace) {
    entry.textContent = summary;
    if (stackTrace != null && stackTrace.trim().isNotEmpty) {
      entry.appendChild(
        HTMLDetailsElement()
          ..appendChild(HTMLElement.summary()..textContent = 'stack trace')
          ..appendChild(HTMLPreElement.pre()..textContent = stackTrace),
      );
    }
  }

  /// The runner writes `ERROR CAUGHT $error $stackTrace` on one line, split
  /// it once the actual error is known.
  void _fixLastError(Object error) {
    final lastError = _lastError;
    final summary = 'ERROR CAUGHT $error';
    if (lastError != null && lastError.$2.startsWith('$summary ')) {
      final (entry, text) = lastError;
      _fillError(entry, summary, text.substring(summary.length + 1));
    }
  }

  bool _isAtEnd(Element element) =>
      element.scrollHeight - element.scrollTop - element.clientHeight < 48;

  void _scrollToEnd() {
    _scroller.scrollTop = _scroller.scrollHeight;
    _outputSection.scrollTop = _outputSection.scrollHeight;
  }

  /// Append an output entry, scrolling to it if [follow] is set or if the
  /// user did not scroll up.
  void _append(Element entry, {bool follow = false}) {
    findContainer();
    follow = follow || (_isAtEnd(_scroller) && _isAtEnd(_outputSection));
    final log = output!;
    log.appendChild(entry);
    while (log.childElementCount > _maxOutputCount) {
      log.firstElementChild!.remove();
    }
    if (follow) {
      _scrollToEnd();
    }
  }

  void _updateStatus() {
    final (state, label) = promptCompleter != null
        ? ('input', 'INPUT')
        : _runningCount > 0
        ? ('running', 'RUNNING')
        : _lastRunFailed
        ? ('error', 'ERROR')
        : ('ready', 'READY');
    _status
      ..setAttribute('data-state', state)
      ..textContent = label;
  }

  bool get _isDark {
    final theme = container!.getAttribute('data-theme');
    if (theme != null) {
      return theme == 'dark';
    }
    return !window.matchMedia('(prefers-color-scheme: light)').matches;
  }

  void _toggleTheme() {
    final theme = _isDark ? 'light' : 'dark';
    container!.setAttribute('data-theme', theme);
    _savePrefs(() => prefs.setString(_prefsThemeKey, theme));
    _updateThemeButton();
  }

  void _updateThemeButton() {
    final dark = _isDark;
    _setLabel(
      _themeButton,
      dark ? 'Switch to light theme' : 'Switch to dark theme',
    );
    _themeButton.textContent = '';
    _themeButton.appendChild(svgIcon(dark ? iconSun : iconMoon));
  }

  void _onDocumentKeyDown(KeyboardEvent event) {
    // Typing anywhere goes to the command line.
    if (event.key.length != 1 ||
        event.key == ' ' ||
        event.ctrlKey ||
        event.metaKey ||
        event.altKey) {
      return;
    }
    final tag = document.activeElement?.tagName;
    if (tag == 'INPUT' || tag == 'TEXTAREA' || tag == 'SELECT') {
      return;
    }
    basicInput!.focus();
  }

  void _onInputKeyDown(KeyboardEvent event) {
    switch (event.key) {
      case 'ArrowUp':
        event.preventDefault();
        _historyMove(-1);
      case 'ArrowDown':
        event.preventDefault();
        _historyMove(1);
      case 'Escape':
        basicInput!.value = '';
        _historyIndex = null;
    }
  }

  void _addHistory(String line) {
    if (_history.isEmpty || _history.last != line) {
      _history.add(line);
      if (_history.length > _maxHistoryCount) {
        _history.removeAt(0);
      }
    }
  }

  void _historyMove(int delta) {
    if (_history.isEmpty) {
      return;
    }
    final input = basicInput!;
    var index = _historyIndex;
    if (index == null) {
      if (delta > 0) {
        return;
      }
      _historyDraft = input.value;
      index = _history.length;
    }
    index += delta;
    if (index < 0) {
      index = 0;
    }
    if (index >= _history.length) {
      _historyIndex = null;
      input.value = _historyDraft;
    } else {
      _historyIndex = index;
      input.value = _history[index];
    }
    input.setSelectionRange(input.value.length, input.value.length);
  }

  /// Process a line typed in the command line.
  ///
  /// It answers the pending prompt if any. Otherwise it is an item number or
  /// shortcut, `-` (or `.`) to go back, `?` for help, anything else going to
  /// the menu `command` handler if declared.
  Future<void> processLine(String line) async {
    if (promptCompleter != null) {
      _answerPrompt(line);
      return;
    }
    line = line.trim();
    if (line.isEmpty) {
      return;
    }
    _addHistory(line);
    final menu = displayedMenu;
    if (menu == null) {
      return;
    }
    if (_exitCommands.contains(line)) {
      await _pop();
      return;
    }
    if (line == _helpCommand) {
      _writeHelp(menu);
      return;
    }
    final item = menu.byCmd(line);
    if (item != null) {
      await _runItem(item);
      return;
    }
    final command = menu.command;
    if (command != null) {
      _append(_line('tm-line-cmd', line), follow: true);
      await _guard(() async {
        final result = command.fn(line);
        if (result is Future) {
          await result;
        }
      }, reportError: true);
      return;
    }
    _append(
      _line('tm-line-error', 'Unknown command "$line", type ? for help'),
      follow: true,
    );
  }

  void _writeHelp(TestMenu menu) {
    final lines = <String>[];
    for (var i = 0; i < menu.length; i++) {
      final item = menu[i];
      lines.add('${(item.cmd ?? '$i').padLeft(3)}  $item');
    }
    if (testMenuManager!.canPop()) {
      lines.add('  -  exit (or .)');
    }
    lines
      ..add('  ?  this help')
      ..add(' $_arrowsUpDown  previous commands')
      ..add('Reloading the page runs the last item again.');
    _info(lines.join('\n'));
  }

  /// Run an action, tracking the running state and swallowing its error
  /// (the menu runner already wrote it unless [reportError] is set).
  Future<void> _guard(
    Future<void> Function() action, {
    TestItem? item,
    bool reportError = false,
  }) async {
    _runningCount++;
    _lastRunFailed = false;
    if (item != null) {
      _running.add(item);
      _itemButtons[item]?.setAttribute('data-running', '');
    }
    _updateStatus();
    try {
      await action();
    } catch (e, st) {
      _lastRunFailed = true;
      _fixLastError(e);
      if (reportError) {
        writeln('ERROR $e\n$st');
      }
    } finally {
      _runningCount--;
      if (item != null) {
        _running.remove(item);
        _itemButtons[item]?.removeAttribute('data-running');
      }
      _updateStatus();
    }
  }

  Future<void> _runItem(TestItem item) async {
    await _guard(() => testMenuManager!.runItem(item), item: item);
  }

  Future<void> _pop() async {
    final manager = testMenuManager!;
    if (!manager.canPop()) {
      _info('Already in the top menu');
      return;
    }
    await _guard(manager.popMenu);
  }

  /// Pop until the menu at [depth] of the stack is active.
  Future<void> _popTo(int depth) async {
    final manager = testMenuManager!;
    while (manager.activeDepth > depth) {
      final before = manager.activeDepth;
      await _pop();
      if (manager.activeDepth >= before) {
        break;
      }
    }
  }

  /// Pop and push menus until [target] is active, false if not reachable
  /// (a dynamic menu that was closed).
  Future<bool> _navigateTo(TestMenu target) async {
    final manager = testMenuManager!;
    final chain = <TestMenu>[];
    for (TestMenu? menu = target; menu != null; menu = menu.parent) {
      chain.insert(0, menu);
    }
    var common = chain.length - 1;
    while (common >= 0 && !manager.stackContainsMenu(chain[common])) {
      common--;
    }
    if (common < 0) {
      return false;
    }
    while (manager.activeMenu != chain[common]) {
      if (!await manager.popMenu()) {
        return false;
      }
    }
    for (var i = common + 1; i < chain.length; i++) {
      await manager.pushMenu(chain[i]);
    }
    return manager.activeMenu == target;
  }

  Future<void> _runRecent(TestItem item) async {
    final parent = item.parent;
    if (parent != null && await _navigateTo(parent)) {
      await _runItem(item);
    } else {
      _info('"${item.name}" is no longer available');
      _recents.remove(item);
      _renderRecents();
    }
  }

  String _itemKey(TestItem item) =>
      item.cmd ?? '${item.parent?.indexOfItem(item) ?? '?'}';

  /// main › 0 write hola
  String _itemPath(TestItem item) {
    final names = <String>[];
    for (var menu = item.parent; menu != null; menu = menu.parent) {
      if (menu is! RootTestMenu) {
        names.insert(0, menu.name);
      }
    }
    return [...names, '${_itemKey(item)} ${item.name}'].join(_pathSeparator);
  }

  void _addRecent(TestItem item) {
    _recents
      ..remove(item)
      ..insert(0, item);
    if (_recents.length > _maxRecentCount) {
      _recents.removeLast();
    }
    _renderRecents();
  }

  void _renderRecents() {
    final quick = _quick;
    quick.textContent = '';
    if (_recents.isEmpty) {
      quick.setAttribute('hidden', '');
      return;
    }
    quick
      ..removeAttribute('hidden')
      ..appendChild(_withClass(HTMLSpanElement(), 'tm-quick-label', 'RECENT'));
    for (final item in _recents) {
      quick.appendChild(
        _button('tm-chip', label: 'Run ${_itemPath(item)}')
          ..appendChild(
            _withClass(HTMLSpanElement(), 'tm-chip-key', _itemKey(item)),
          )
          ..appendChild(Text(' ${item.name}'))
          ..onClick.listen((_) => _runRecent(item)),
      );
    }
  }

  /// Append `> _root_ > main` to [parent], clickable for the breadcrumb.
  void _appendMenuPath(Element parent, {required bool clickable}) {
    final stack = testMenuManager!.stackMenus;
    for (var i = 0; i < stack.length; i++) {
      final depth = i;
      final last = i == stack.length - 1;
      parent.appendChild(_withClass(HTMLSpanElement(), 'tm-sep', '>'));
      final name = stack[i].menu.name;
      final HTMLElement segment;
      if (clickable) {
        segment = _button('tm-crumb', text: name);
        if (!last) {
          segment
            ..title = 'Back to $name'
            ..onClick.listen((_) => _popTo(depth));
        }
      } else {
        segment = HTMLSpanElement()..textContent = name;
      }
      if (last) {
        segment.setAttribute('aria-current', 'page');
      }
      parent.appendChild(segment);
    }
  }

  void _renderCrumbs() {
    final path = _crumbPath;
    path.textContent = '';
    _appendMenuPath(path, clickable: true);
    _crumbMeta.textContent = window.location.hash;
  }

  void _renderKeys(TestMenu menu) {
    final keys = _keys;
    keys.textContent = '';
    final count = menu.length < _maxKeyCount ? menu.length : _maxKeyCount;
    for (var i = 0; i < count; i++) {
      final item = menu[i];
      keys.appendChild(
        _button('tm-key', text: item.cmd ?? '$i', label: '$item')
          ..onClick.listen((_) => _runItem(item)),
      );
    }
    if (testMenuManager!.canPop()) {
      keys.appendChild(
        _button('tm-key tm-key-exit', text: '-', label: 'exit')
          ..onClick.listen((_) => _pop()),
      );
    }
  }

  Element _menuRow({
    required String key,
    required String name,
    required String className,
    required void Function() onTap,
    String? tag,
  }) {
    final button = _button('tm-item $className')
      ..appendChild(_withClass(HTMLSpanElement(), 'tm-item-key', key))
      ..appendChild(_withClass(HTMLSpanElement(), 'tm-item-name', name));
    if (tag != null) {
      button.appendChild(_withClass(HTMLSpanElement(), 'tm-item-tag', tag));
    }
    button.onClick.listen((_) => onTap());
    return HTMLLIElement()..appendChild(button);
  }

  // for href
  List<String> getMenuStackNames([TestItem? item]) {
    final list = <String>[];

    TestMenu? lastMenu;
    //devPrint(testMenuManager.stackMenus);
    for (var i = testMenuManager!.stackMenus.length - 1; i >= 0; i--) {
      final menu = testMenuManager!.stackMenus[i].menu;

      int index;

      if (lastMenu == null) {
        lastMenu = testMenuManager!.activeMenu;
        if (item == null) {
          continue;
        }
        // ignore: dead_code
        if (false) {
          // item is DevTestItem) {
          // index = stackMenus[stackMenus.length - 2].indexOfItem(item);
          // nothing
          continue;
        } else {
          index = testMenuManager!.activeMenu!.indexOfItem(item);
        }
      } else {
        index = menu.indexOfMenu(lastMenu);
        lastMenu = menu;
      }

      list.insert(0, index.toString());
    }
    return list;
  }

  @override
  Future preProcessItem(TestItem item) async {
    findContainer();
    window.location.hash = '#${getMenuStackNames(item).join('_')}';
    _crumbMeta.textContent = window.location.hash;
    _append(_line('tm-line-cmd', _itemPath(item)), follow: true);
    _addRecent(item);
    // process after setting the hash to allow reload in case of crash in processing
    await super.preProcessItem(item);
  }

  void displayMenu(TestMenu menu) {
    findContainer();
    final depth = testMenuManager!.activeDepth;
    if (displayedMenu == menu && _displayedDepth == depth) {
      return;
    }
    displayedMenu = menu;
    _displayedDepth = depth;

    final title = _withClass(HTMLHeadingElement.h3(), 'tm-menu-title');
    _appendMenuPath(title, clickable: false);

    final list = _withClass(HTMLUListElement(), 'tm-menu-list')
      ..setAttribute('role', 'list');
    _itemButtons.clear();
    if (depth > 0) {
      list.appendChild(
        _menuRow(
          key: '-',
          name: 'exit',
          className: 'tm-item-exit',
          onTap: _pop,
        ),
      );
    }
    for (var i = 0; i < menu.length; i++) {
      final item = menu[i];
      final isMenu = item is MenuTestItem;
      final row = _menuRow(
        key: item.cmd ?? '$i',
        name: item.name,
        className: isMenu ? 'tm-item-menu' : 'tm-item-run',
        tag: item is RunnableTestItem && item.test == true ? 'test' : null,
        onTap: () => _runItem(item),
      );
      final button = row.firstElementChild!;
      _itemButtons[item] = button;
      if (_running.contains(item)) {
        button.setAttribute('data-running', '');
      }
      list.appendChild(row);
    }
    if (menu.length == 0) {
      list.appendChild(
        _withClass(HTMLLIElement(), 'tm-line-info', 'Empty menu'),
      );
    }

    final section = menuContainer!;
    section.textContent = '';
    section
      ..appendChild(title)
      ..appendChild(list)
      ..scrollTop = 0;
    _renderCrumbs();
    _renderKeys(menu);
    // Stacked layout: the menu is below the output.
    _scroller.scrollTop = _scroller.scrollHeight;
  }

  @override
  void presentMenu(TestMenu menu) {
    displayMenu(menu);
  }
}

/// Init the web test menu, [prefs] (theme and menu layout) default to the
/// browser local storage.
Future<void> initTestMenuBrowser({
  List<String>? jsFiles,
  PrefsLight? prefs,
}) async {
  await testMenuLoadJs(jsFiles);
  _testMenuManagerBrowser = TestMenuManagerBrowser(prefs: prefs)
    ..findContainer();

  testMenuPresenter = _testMenuManagerBrowser!;

  initTestMenuManager();
  final hash = window.location.hash;
  testMenuManager!.initCommands = TestMenuManager.initCommandsFromHash(hash);
}

Future testMenuLoadJs(List<String>? jsFiles) async {
  if (jsFiles != null) {
    for (final jsFile in jsFiles) {
      await loadJavascriptScript(jsFile);
    }
  }
}

TestMenuManagerBrowser? _testMenuManagerBrowser;

/// Compat
Future<void> mainMenu(void Function() declare) async {
  await mainMenuWeb(declare);
}

/// Main menu declaration
Future<void> mainMenuWeb(void Function() declare) async {
  await initTestMenuBrowser();
  declare();
}
