# Changelog

## 0.9.1

- New web console look: dark/light theme, breadcrumb, recent items, keypad,
  command line with history (`-` back, `?` help, menu `command` handler),
  running/prompt/error status, styles injected (no css asset to serve)
- `TestMenuManagerBrowser.processLine` and `clearOutput`
- Menu can be hidden, and its height limited (percent of height, min and max)
  when below the output; theme and menu layout saved in a `PrefsLight`
  (`tekartik_prefs_browser` local storage by default,
  `initTestMenuBrowser(prefs: ...)`)
- Fix `â€º` displayed instead of `›` in the output with ddc on a page without
  charset (examples now declare `<meta charset="UTF-8">`)
- `example/test_menu_web_example.dart`

## 0.4.8

- console.log all writes

## 0.4.0

- Add enter/leave support

## 0.3.1

- limit output to 100 lines on browser

## 0.3.0

- Add DDC support

## 0.2.0

- Add support for shortcut commands
- commands can be used when calling

## 0.1.0

- Initial version
