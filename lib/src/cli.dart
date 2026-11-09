import 'render.dart';
import 'template.dart';

const String _usage = 'usage: slotprompt render [--var NAME=VALUE]... [--list NAME=A,B,...]...\n       slotprompt vars\n';

/// The result of one command-line invocation.
class Result {
  /// Creates a command result with [status], [out] and [err].
  const Result(this.status, this.out, this.err);

  /// The process exit status.
  final int status;

  /// Standard output.
  final String out;

  /// Standard error.
  final String err;
}

class _Invocation {
  const _Invocation(this.status, this.command, this.values, this.error);

  final int status;
  final String? command;
  final Map<String, Object> values;
  final String? error;
}

_Invocation _validate(List<String> args) {
  if (args.isEmpty) return const _Invocation(2, null, {}, _usage);
  final command = args.first;
  if (command == 'help' || command == '-h' || command == '--help') {
    return const _Invocation(0, null, {}, 'help');
  }
  if (command == '--version') return const _Invocation(0, null, {}, 'version');
  if (command == 'vars') {
    if (args.length != 1) return const _Invocation(2, null, {}, 'vars takes no arguments');
    return const _Invocation(0, 'vars', {}, null);
  }
  if (command != 'render') return _error('unknown command $command');

  final values = <String, Object>{};
  var index = 1;
  while (index < args.length) {
    final option = args[index];
    if (option != '--var' && option != '--list') return _error('unexpected argument $option');
    final kind = option;
    if (index + 1 >= args.length) return _error('$kind needs NAME=VALUE');
    final typed = args[index + 1];
    final equals = typed.indexOf('=');
    final name = equals < 0 ? '' : typed.substring(0, equals);
    if (equals < 0 || !isValidName(name)) return _error('bad $kind argument: $typed');
    if (values.containsKey(name)) return _error('$name given twice');
    final value = typed.substring(equals + 1);
    values[name] = kind == '--var' ? value : _parseList(value);
    index += 2;
  }
  return _Invocation(0, 'render', values, null);
}

_Invocation _error(String message) => _Invocation(2, null, {}, message);

List<String> _parseList(String value) {
  if (value.isEmpty) return <String>[];
  final items = <String>[];
  final item = StringBuffer();
  for (var index = 0; index < value.length; index++) {
    final character = value[index];
    if (character == r'\' && index + 1 < value.length) {
      final next = value[index + 1];
      if (next == ',' || next == r'\') {
        item.write(next);
        index++;
      } else {
        item.write(character);
      }
    } else if (character == ',') {
      items.add(item.toString());
      item.clear();
    } else {
      item.write(character);
    }
  }
  items.add(item.toString());
  return items;
}

/// Returns whether [args] is a valid invocation that consumes standard input.
bool readsStdin(List<String> args) {
  final validated = _validate(args);
  return validated.status == 0 && (validated.command == 'render' || validated.command == 'vars');
}

/// Runs the command [args] against template text [input], without accessing process I/O.
Result run(List<String> args, String input) {
  final invocation = _validate(args);
  if (args.isEmpty) return Result(2, '', _usage);
  if (invocation.error != null) {
    if (invocation.error == 'help') return Result(0, _usage, '');
    if (invocation.error == 'version') return const Result(0, 'slotprompt 0.1.0\n', '');
    return Result(invocation.status, '', 'slotprompt: ${invocation.error}\n');
  }
  try {
    final nodes = parseTemplate(input);
    if (invocation.command == 'vars') {
      return Result(0, freeNames(nodes).map((name) => '$name\n').join(), '');
    }
    return Result(0, renderTemplate(nodes, invocation.values), '');
  } on TemplateError catch (error) {
    return Result(1, '', 'slotprompt: ${error.pos.line}:${error.pos.column}: ${error.message}\n');
  }
}
