import 'package:dart_printf/dart_printf.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('First Test', () {
      expect(printf('%s %s XDD', 'hello', 'world'), 'hello world XDD');
      expect(printf([1, 2, 3]), '[1, 2, 3]');
      expect(printf(1), '1');
      expect(printf(true), 'true');
      expect(printf('%s %o', 'hi', [1,2], false), 'hi [1, 2]');
    });
  });
}
