void _typeWarn(RegExpMatch m, int index, dynamic v) {
  var type = '';
  switch (m.namedGroup('f')) {
    case 's':
      type = 'String';
      break;
    case 'd':
    case 'i':
    case 'x':
    case 'X':
      type = 'int';
      break;
    case 'f':
    case 'e':
      type = 'double';
      break;
    case 'b':
      type = 'bool';
      break;
    default:
  }

  // 不抛出错误，只给出警告
  print(
      '[[ printf ]]: The format string "${m[1]}" requires a parameter of type "${type}", but the variable parameter ${index + 1} has type "${v.runtimeType}"');
}

var _fexp = RegExp(r'(%(?<n>\d*)(?<f>[\w\W]))');
String _printf(List<dynamic> arguments, [bool needPrint = true]) {
  if (arguments.isEmpty) return '';

  // format string
  var format = arguments.first;

  // 如果不是string，直接打印
  if (format is! String) {
    if (needPrint) print(format);
    return format.toString();
  }

  var formatList = [];
  var matches = _fexp.allMatches(format);

  // 剩余的参数
  var args = arguments.getRange(1, arguments.length).toList();

  // No formatting required
  if (matches.isEmpty || args == null || args.isEmpty) {
    if (needPrint) print(format);
    return format;
  }

  // string index
  var start = 0;

  void _next(m, arg) {
    formatList.add(format.substring(start, m.start));
    formatList.add(arg);
    start = m.end;
  }

  for (var i = 0; i < args.length; i++) {
    var arg = args[i];

    // 无视掉多余的args
    if (i >= matches.length) break;

    var m = matches.elementAt(i);
    var f = m.namedGroup('f'); // %s %x 这种
    var n = m.namedGroup('n'); // %4x中的4
    switch (f) {
      case 's':
        if (arg is! String) _typeWarn(m, i, arg);
        _next(m, arg);
        break;
      case 'd':
      case 'i':
        if (arg is int) {
          _next(m, arg);
          break;
        }

        if (arg is bool) {
          _next(m, arg ? 1 : 0);
          break;
        }

        _typeWarn(m, i, arg);
        _next(m, arg.toString());
        break;
      case 'f':
      case 'e':
        if (arg is! double) _typeWarn(m, i, arg);
        _next(m, arg);
        break;
      case 'b':
        if (arg is! bool) _typeWarn(m, i, arg);
        _next(m, arg);
        break;
      case 'x':
      case 'X':
        var isUpper = f == 'X';
        var width = int.parse(n.isEmpty ? '0' : n);
        if (arg is int) {
          var hex = arg.toRadixString(16).padLeft(width, '0');
          _next(m, isUpper ? hex.toUpperCase() : hex);
          break;
        } else if (arg is bool) {
          var hex = (arg ? 1 : 0).toRadixString(16).padLeft(width, '0');
          _next(m, isUpper ? hex.toUpperCase() : hex);
          break;
        }

        _next(m, arg.toString());
        _typeWarn(m, i, arg);
        break;
      case 'o':
        _next(m, arg.toString());
        break;
      default:
        print(
            '[[ printf ]]: The type field character "${m.namedGroup('f')}" in the format specifier is unknown');
    }
  }

  formatList.add(format.substring(start, format.length));

  var sFormat = formatList.join();
  if (needPrint) print(sFormat);
  return sFormat;
}

class _Printf {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isMethod) return super.noSuchMethod(invocation);

    var arguments = invocation.positionalArguments;
    _printf(arguments, true);
  }
}

class _Printfr {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isMethod) return super.noSuchMethod(invocation);

    var arguments = invocation.positionalArguments;
    return _printf(arguments, false);
  }
}

///
/// Automatic printing, no return value.
///
/// `void printf(String format, dynamic arg1, dynamic arg2, ...)`
///
///```txt
/// %s String
/// %d int/bool
/// %i int/bool
/// %f double
/// %e double
/// %b bool
/// %x int/bool
/// %X int/bool
/// %nx int/bool
/// %nX int/bool
/// %o dynamic to string
/// ```
/// ## Example
/// ```dart
/// // hi--1--1.1--1.2--true--0--a--A--1--0--000a--000A--0000000a--0000000A--0
/// printf(
///   '%s--%d--%f--%e--%b--%d--%x--%X--%x--%X--%4x--%4X--%8x--%8X--%2X',
///   'hi', 1, 1.1, 1.2, true, false, 10, 10, true, false, 10, 10, 10, 10, true
/// );
/// ```
dynamic printf = _Printf();

///
/// No printing, return the formatted value.
///
/// `String printfr(String format, dynamic arg1, dynamic arg2, ...)`
///
///```txt
/// %s String
/// %d int/bool
/// %i int/bool
/// %f double
/// %e double
/// %b bool
/// %x int/bool
/// %X int/bool
/// %nx int/bool
/// %nX int/bool
/// %o dynamic to string
/// ```
/// ## Example
/// ```dart
/// // hi--1--1.1--1.2--true--0--a--A--1--0--000a--000A--0000000a--0000000A--0
/// printf(
///   '%s--%d--%f--%e--%b--%d--%x--%X--%x--%X--%4x--%4X--%8x--%8X--%2X',
///   'hi', 1, 1.1, 1.2, true, false, 10, 10, true, false, 10, 10, 10, 10, true
/// );
/// ```
dynamic printfr = _Printfr();
