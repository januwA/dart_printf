import 'package:dart_printf/dart_printf.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('First Test', () {
      expect(printfr('%s %s XDD', 'hello', 'world'), 'hello world XDD');
      expect(printfr([1, 2, 3]), '[1, 2, 3]');
      expect(printfr(1), '1');
      expect(printfr(true), 'true');
      expect(printfr('%s %o', 'hi', [1,2], false), 'hi [1, 2]');
    });
  });
}
