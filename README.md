# test_menu.dart

Manual test menus for Dart programs: declare menus and items once, run them
by hand on the console, in a browser page or in node.

* [test_menu](test_menu): the declarations (`tekartik_test_menu`).
* [test_menu_io](test_menu_io): the console runner (`dart run`).
* [test_menu_browser](test_menu_browser): the web page runner, and the
  universal entry point (browser and console).
* [test_menu_node](test_menu_node): the node runner.
* [test_menu_example](test_menu_example): starters to copy
  (`starter_universal`; `starter_browser` uses the deprecated `dart:html`
  compat library).

The Flutter runner is
[tekartik/test_menu_flutter](https://github.com/tekartik/test_menu_flutter).

## Browser

```yaml
dependencies:
  tekartik_test_menu_browser:
    git:
      url: https://github.com/tekartik/test_menu.dart
      path: test_menu_browser
```
