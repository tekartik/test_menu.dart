library;

import 'package:tekartik_test_menu_browser/key_value_universal.dart';
import 'package:test/test.dart';

var myVar = 'n1xqmEiN4xLJy6bQDGNk.myTestVar'.kvFromVar(defaultValue: '12345');
void main() {
  group('universal vars', () {
    test('init', () async {
      var myVar = 'n1xqmEiN4xLJy6bQDGNk.myTestVar1'.kvFromVar(
        defaultValue: '12345',
      );
      expect(myVar.value, '12345');
      expect(myVar.valid, true);
      var myVar2 = 'n1xqmEiN4xLJy6bQDGNk.myTestVar2'.kvFromVar();
      expect(myVar2.value, isNull);
      expect(myVar2.valid, false);
    });
    test('raw delete/set/get', () async {
      await deleteVar(myVar.key);
      expect(getVar(myVar.key), isNull);
      await setVar(myVar.key, 'test');
      expect(getVar(myVar.key), 'test');
      await setVar(myVar.key, 'test1');
      expect(getVar(myVar.key), 'test1');
      await deleteVar(myVar.key);
      expect(getVar(myVar.key), isNull);
    });
    test('delete/set/get', () async {
      var myVar = 'n1xqmEiN4xLJy6bQDGN1.myTestVar'.kvFromVar();
      await myVar.delete();
      expect(myVar.value, isNull);
      expect(myVar.get(), isNull);
      var myVarName2 = myVar.key.kvFromVar();
      expect(myVarName2.value, isNull);
      await myVar.set('test');
      expect(myVar.value, 'test');
      expect(myVar.get(), 'test');
      expect(myVarName2.value, isNull);
      expect(myVarName2.get(), 'test');
      expect(myVarName2.value, 'test');
    });
  });
}
