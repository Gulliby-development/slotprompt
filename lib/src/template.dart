import 'filters.dart';

/// A one-based source position measured in Unicode code points.
class Pos {
  /// Creates a source position.
  const Pos(this.line, this.column);

  /// The one-based line number.
  final int line;

  /// The one-based code-point column number.
  final int column;
}

/// A positioned template syntax or evaluation error.
class TemplateError implements Exception {
  /// Creates an error at [pos] with a readable [message].
  const TemplateError(this.pos, this.message);

  /// The position associated with the error.
  final Pos pos;

  /// The error message without command-line formatting.
  final String message;

  @override
  String toString() => message;
}

/// Base class for nodes in a parsed template.
abstract class Node {
  /// Creates a template node.
  const Node();
}

/// A literal text fragment.
class TextNode extends Node {
  /// Creates a text node containing [text].
  const TextNode(this.text);

  /// The literal text.
  final String text;
}

/// A variable reference and its ordered filters.
class VariableNode extends Node {
  /// Creates a variable node at [pos] for [name] and [filters].
  const VariableNode(this.pos, this.name, this.filters);

  /// The opening-tag position.
  final Pos pos;

  /// The variable name.
  final String name;

  /// Filters in application order.
  final List<Filter> filters;
}

/// A conditional or iteration block and its child sequences.
class BlockNode extends Node {
  /// Creates a block node at [pos].
  const BlockNode(this.pos, this.kind, this.name, this.body, this.elseBody);

  /// Opening tag position.
  final Pos pos;

  /// Block kind (`if`, `unless`, or `each`).
  final String kind;

  /// Condition or iteration source.
  final String name;

  /// Main body.
  final List<Node> body;

  /// Alternate conditional body.
  final List<Node> elseBody;
}

/// Returns whether [value] is an ASCII template variable name.
bool isValidName(String value) {
  if (value.isEmpty) return false;
  final first = value.codeUnitAt(0);
  if (!_isAsciiLetter(first) && first != 95) return false;
  for (var index = 1; index < value.length; index++) {
    final unit = value.codeUnitAt(index);
    if (!_isAsciiLetter(unit) && (unit < 48 || unit > 57) && unit != 95) return false;
  }
  return true;
}

/// Returns whether [unit] is one of the template's four ASCII whitespace characters.
bool isTemplateWhitespace(int unit) => unit == 32 || unit == 9 || unit == 13 || unit == 10;

/// Trims only the four ASCII whitespace characters recognized inside template tags.
String trimTemplateWhitespace(String value) {
  var start = 0;
  var end = value.length;
  while (start < end && isTemplateWhitespace(value.codeUnitAt(start))) {
    start++;
  }
  while (end > start && isTemplateWhitespace(value.codeUnitAt(end - 1))) {
    end--;
  }
  return value.substring(start, end);
}

bool _isAsciiLetter(int unit) => (unit >= 65 && unit <= 90) || (unit >= 97 && unit <= 122);

/// Parses [source] into text and variable nodes, reporting the first positioned syntax error.
List<Node> parseTemplate(String source) {
  final points = source.runes.toList(growable: false);
  final nodes = <Node>[];
  final stack = <_BlockFrame>[];
  var target = nodes;
  final text = <int>[];
  var line = 1;
  var column = 1;
  var index = 0;

  void advance(int point) {
    if (point == 10) {
      line++;
      column = 1;
    } else {
      column++;
    }
  }

  void flushText() {
    if (text.isNotEmpty) {
      target.add(TextNode(String.fromCharCodes(text)));
      text.clear();
    }
  }

  while (index < points.length) {
    if (points[index] == 92 && index + 2 < points.length && points[index + 1] == 123 && points[index + 2] == 123) {
      text.add(123);
      text.add(123);
      advance(points[index]);
      advance(points[index + 1]);
      advance(points[index + 2]);
      index += 3;
      continue;
    }
    if (points[index] != 123 || index + 1 >= points.length || points[index + 1] != 123) {
      text.add(points[index]);
      advance(points[index]);
      index++;
      continue;
    }

    flushText();
    final pos = Pos(line, column);
    advance(points[index]);
    advance(points[index + 1]);
    index += 2;
    final body = <int>[];
    var closed = false;
    while (index < points.length) {
      if (points[index] == 125 && index + 1 < points.length && points[index + 1] == 125) {
        advance(points[index]);
        advance(points[index + 1]);
        index += 2;
        closed = true;
        break;
      }
      body.add(points[index]);
      advance(points[index]);
      index++;
    }
    if (!closed) throw TemplateError(pos, 'unclosed tag');

    var start = 0;
    var end = body.length;
    while (start < end && isTemplateWhitespace(body[start])) {
      start++;
    }
    while (end > start && isTemplateWhitespace(body[end - 1])) {
      end--;
    }
    if (start == end) throw TemplateError(pos, 'empty tag');
    if (body[start] == 33) continue;
    final tag = String.fromCharCodes(body.sublist(start, end));
    if (tag.startsWith('#')) {
      final opening = trimTemplateWhitespace(tag.substring(1));
      var separator = -1;
      for (var i = 0; i < opening.length; i++) {
        if (isTemplateWhitespace(opening.codeUnitAt(i))) {
          separator = i;
          break;
        }
      }
      final kind = separator < 0 ? opening : opening.substring(0, separator);
      if (kind != 'if' && kind != 'unless' && kind != 'each') throw TemplateError(pos, 'unknown block $kind');
      final name = separator < 0 ? '' : trimTemplateWhitespace(opening.substring(separator));
      if (!isValidName(name)) throw TemplateError(pos, 'bad name');
      final block = BlockNode(pos, kind, name, <Node>[], <Node>[]);
      target.add(block);
      stack.add(_BlockFrame(block));
      target = block.body;
      continue;
    }
    if (tag.startsWith('/')) {
      final kind = trimTemplateWhitespace(tag.substring(1));
      if (kind != 'if' && kind != 'unless' && kind != 'each') throw TemplateError(pos, 'unknown block $kind');
      if (stack.isEmpty || stack.last.block.kind != kind) throw TemplateError(pos, 'unexpected {{/$kind}}');
      stack.removeLast();
      target = stack.isEmpty
          ? nodes
          : stack.last.inElse
          ? stack.last.block.elseBody
          : stack.last.block.body;
      continue;
    }
    if (tag == 'else') {
      if (stack.isEmpty || stack.last.block.kind == 'each' || stack.last.inElse) throw TemplateError(pos, 'unexpected {{else}}');
      stack.last.inElse = true;
      target = stack.last.block.elseBody;
      continue;
    }

    final segments = _splitFilters(tag);
    final name = trimTemplateWhitespace(segments.first);
    if (!isValidName(name)) throw TemplateError(pos, 'bad name');
    final filters = <Filter>[];
    for (final segment in segments.skip(1)) {
      final part = trimTemplateWhitespace(segment);
      if (part.isEmpty) throw TemplateError(pos, 'empty filter');
      filters.add(parseFilter(part, pos));
    }
    target.add(VariableNode(pos, name, List<Filter>.unmodifiable(filters)));
  }
  if (stack.isNotEmpty) {
    final block = stack.last.block;
    throw TemplateError(block.pos, 'unclosed {{#${block.kind}}}');
  }
  flushText();
  return nodes;
}

List<String> _splitFilters(String tag) {
  final segments = <String>[];
  final current = StringBuffer();
  var quoted = false;
  var escaped = false;
  for (final point in tag.runes) {
    final character = String.fromCharCode(point);
    if (quoted && escaped) {
      current.write(character);
      escaped = false;
    } else if (quoted && character == r'\') {
      current.write(character);
      escaped = true;
    } else if (character == '"') {
      current.write(character);
      quoted = !quoted;
    } else if (character == '|' && !quoted) {
      segments.add(current.toString());
      current.clear();
    } else {
      current.write(character);
    }
  }
  segments.add(current.toString());
  return segments;
}

class _BlockFrame {
  _BlockFrame(this.block);
  final BlockNode block;
  bool inElse = false;
}
