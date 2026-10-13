import 'package:tekartik_test_menu/src/expect.dart' as tm;
import 'package:tekartik_test_menu/test.dart' as tm show isNull, isTrue, fail;
import 'package:test/test.dart';

/// The message of the [tm.TestFailure] thrown by [body].
String failureMessage(void Function() body) {
  try {
    body();
  } on tm.TestFailure catch (e) {
    return e.message;
  }
  fail('no TestFailure thrown');
}

void main() {
  group('expect', () {
    test('match', () {
      tm.expect(1, 1);
      tm.expect(null, tm.isNull);
    });
    test('equals failure', () {
      var message = failureMessage(() => tm.expect(1, 2));
      expect(message, contains('Expected: <2>'));
      expect(message, contains('Actual: <1>'));
    });
    test('string failure', () {
      var message = failureMessage(() => tm.expect('a', 'b'));
      expect(message, contains("Expected: 'b'"));
      expect(message, contains("Actual: 'a'"));
      expect(message, contains('Which:'));
    });
    test('matcher failure', () {
      var message = failureMessage(() => tm.expect(1, tm.isNull));
      expect(message, contains('Expected: null'));
      expect(message, isNot(contains('Instance of')));
      message = failureMessage(() => tm.expect(1, tm.isTrue));
      expect(message, contains('Expected: true'));
    });
    test('reason', () {
      var message = failureMessage(() => tm.expect(1, 2, reason: 'my reason'));
      expect(message, contains('my reason'));
    });
    test('skip', () {
      tm.expect(1, 2, skip: true);
      tm.expect(1, tm.isNull, skip: 'not now');
      expect(() => tm.expect(1, 1, skip: 1), throwsArgumentError);
    });
    test('fail', () {
      expect(() => tm.fail('failed'), throwsA(isA<tm.TestFailure>()));
    });
  });
}
