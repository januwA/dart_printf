import 'package:dart_printf/dart_printf.dart';

void main() {
  printf(
    '%s--%d--%f--%e--%b--%d--%x--%X--%x--%X--%4x--%4X--%8x--%8X--%2X--%o',
    'hi', 1, 1.1, 1.2, true, false, 10, 10, true, false, 10, 10, 10, 10, true, []
  );

  printf('hello %s, [%s] lib', 'world', 'printf');
  print(printfr('hello %s, [%s] lib', 'world', 'printf'));

  printf('Dart');
}
