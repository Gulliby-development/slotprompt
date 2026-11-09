import 'template.dart';

/// A parsed filter in a variable pipeline.
class Filter {
  /// Creates a filter with its [name], [text] argument, and numeric [number] argument.
  const Filter(this.name, this.text, this.number);

  /// The filter name.
  final String name;

  /// The text argument.
  final String text;

  /// The numeric argument.
  final int number;
}

/// Parses [part] as a filter and validates its complete argument.
Filter parseFilter(String part, Pos pos) {
  final normalized = trimTemplateWhitespace(part);
  var end = 0;
  while (end < normalized.length && !isTemplateWhitespace(normalized.codeUnitAt(end))) {
    end++;
  }
  final name = normalized.substring(0, end);
  if (name.isEmpty) throw TemplateError(pos, 'empty filter');
  const known = <String>{'upper', 'lower', 'trim', 'json', 'default', 'truncate', 'indent'};
  if (!known.contains(name)) throw TemplateError(pos, 'unknown filter $name');
  final argument = trimTemplateWhitespace(normalized.substring(end));
  if (name == 'upper' || name == 'lower' || name == 'trim' || name == 'json') {
    if (argument.isNotEmpty) throw TemplateError(pos, 'filter $name takes no argument');
    return Filter(name, '', 0);
  }
  if (name == 'default') {
    final decoded = _decodeDefault(argument);
    if (decoded == null) throw TemplateError(pos, 'bad argument for default');
    return Filter(name, decoded, 0);
  }
  if (argument.isEmpty || argument.length > 4) {
    throw TemplateError(pos, 'bad argument for $name');
  }
  var number = 0;
  for (final unit in argument.codeUnits) {
    if (unit < 48 || unit > 57) throw TemplateError(pos, 'bad argument for $name');
    number = number * 10 + unit - 48;
  }
  if (number == 0) throw TemplateError(pos, 'bad argument for $name');
  return Filter(name, '', number);
}

String? _decodeDefault(String argument) {
  if (argument.length < 2 || argument.codeUnitAt(0) != 34 || argument.codeUnitAt(argument.length - 1) != 34) return null;
  final result = StringBuffer();
  for (var index = 1; index < argument.length - 1; index++) {
    final unit = argument.codeUnitAt(index);
    if (unit == 34) return null;
    if (unit == 92) {
      if (index + 1 >= argument.length - 1) return null;
      final escaped = argument.codeUnitAt(++index);
      if (escaped != 34 && escaped != 92) return null;
      result.writeCharCode(escaped);
    } else {
      result.writeCharCode(unit);
    }
  }
  return result.toString();
}

/// Applies [filter] to [value] using the specified ASCII and Unicode-safe rules.
String applyFilter(Filter filter, String value) {
  switch (filter.name) {
    case 'upper':
      return String.fromCharCodes(value.runes.map((point) => point >= 97 && point <= 122 ? point - 32 : point));
    case 'lower':
      return String.fromCharCodes(value.runes.map((point) => point >= 65 && point <= 90 ? point + 32 : point));
    case 'trim':
      var start = 0;
      var end = value.length;
      while (start < end && isTemplateWhitespace(value.codeUnitAt(start))) {
        start++;
      }
      while (end > start && isTemplateWhitespace(value.codeUnitAt(end - 1))) {
        end--;
      }
      return value.substring(start, end);
    case 'json':
      return _jsonString(value);
    case 'default':
      return value.isEmpty ? filter.text : value;
    case 'truncate':
      final points = value.runes.toList(growable: false);
      return points.length > filter.number ? '${String.fromCharCodes(points.take(filter.number))}...' : value;
    case 'indent':
      final spaces = ' ' * filter.number;
      return value.replaceAll('\n', '\n$spaces');
    default:
      return value;
  }
}

String _jsonString(String value) {
  final result = StringBuffer('"');
  const hex = '0123456789abcdef';
  for (final point in value.runes) {
    switch (point) {
      case 34:
        result.write(r'\"');
      case 92:
        result.write(r'\\');
      case 10:
        result.write(r'\n');
      case 13:
        result.write(r'\r');
      case 9:
        result.write(r'\t');
      case 8:
        result.write(r'\b');
      case 12:
        result.write(r'\f');
      default:
        if (point < 32) {
          result.write('\\u00${hex[(point >> 4) & 15]}${hex[point & 15]}');
        } else {
          result.writeCharCode(point);
        }
    }
  }
  result.write('"');
  return result.toString();
}
