void _typeErr(RegExpMatch m, int index, dynamic v) {
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

  throw FormatException(
      '"printf": 格式字符串"${m[1]}"需要类型"${type}"的参数，但可变参数 ${index} 拥有了类型"${v.runtimeType}"');
}

var _fexp = RegExp(r'(%(?<n>\d*)(?<f>[\w\W]))');
String _printf(List<dynamic> arguments, [bool needPrint = true]) {
  if (arguments.isEmpty) return '';

  var format = arguments.first;

  if (format is! String) {
    if (needPrint) print(format);
    return format.toString();
  }

  var formatList = [];
  var matches = _fexp.allMatches(format);

  var args = arguments.getRange(1, arguments.length).toList();
  // No formatting required
  if (matches.isEmpty || args == null || args.isEmpty) {
    if (needPrint) print(format);
    return format;
  }

  var start = 0;
  void _next(m, v) {
    formatList.add(format.substring(start, m.start));
    formatList.add(v);
    start = m.end;
  }

  for (var i = 0; i < args.length; i++) {
    var v = args[i];

    // 无视掉多余的args
    if (i >= matches.length) {
      break;
    }
    var m = matches.elementAt(i);
    var f = m.namedGroup('f');
    var n = m.namedGroup('n');
    switch (f) {
      case 's':
        if (v is String) {
          _next(m, v);
        } else {
          _typeErr(m, i + 1, v);
        }
        break;
      case 'd':
      case 'i':
        if (v is int) {
          _next(m, v);
        } else if (v is bool) {
          _next(m, v ? 1 : 0);
        } else {
          _typeErr(m, i + 1, v);
        }
        break;
      case 'f':
      case 'e':
        if (v is double) {
          _next(m, v);
        } else {
          _typeErr(m, i + 1, v);
        }
        break;
      case 'b':
        if (v is bool) {
          _next(m, v);
        } else {
          _typeErr(m, i + 1, v);
        }
        break;
      case 'x':
      case 'X':
        var isUpper = f == 'X';
        var width = int.parse(n.isEmpty ? '0' : n);
        if (v is int) {
          var hex = v.toRadixString(16).padLeft(width, '0');
          _next(m, isUpper ? hex.toUpperCase() : hex);
        } else if (v is bool) {
          var hex = (v ? 1 : 0).toRadixString(16).padLeft(width, '0');
          _next(m, isUpper ? hex.toUpperCase() : hex);
        } else {
          _typeErr(m, i + 1, v);
        }
        break;
      case 'o':
        _next(m, v.toString());
        break;
      default:
        throw FormatException(
            '"printf": 格式说明符中的类型字段字符"${m.namedGroup('f')}"未知');
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
