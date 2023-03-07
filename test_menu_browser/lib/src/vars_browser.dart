import 'dart:html' as html;

void setLocalStorageVar(String key, String value) =>
    html.window.localStorage[key] = value;

String? getLocalStorageVar(String key) => html.window.localStorage[key];

/// Delete an env var
void deleteLocalStorageVar(String key) {
  html.window.localStorage.remove(key);
}
