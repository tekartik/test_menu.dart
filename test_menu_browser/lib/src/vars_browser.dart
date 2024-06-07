import 'package:tekartik_browser_utils/storage_utils.dart';

@Deprecated('Use webLocalStorageSet')
void setLocalStorageVar(String key, String value) =>
    webLocalStorageSet(key, value);

@Deprecated('Use webLocalStorageGet')
String? getLocalStorageVar(String key) => webLocalStorageGet(key);

/// Delete an env var
@Deprecated('Use webLocalStorageRemove')
void deleteLocalStorageVar(String key) => webLocalStorageRemove(key);
