import 'filters.dart';
import 'template.dart';

/// Renders parsed [nodes] using [values], throwing the first evaluation error.
String renderTemplate(List<Node> nodes, Map<String, Object> values) {
  final output = StringBuffer();

  void visit(List<Node> sequence, Map<String, Object> scope) {
    for (final node in sequence) {
      if (node is TextNode) {
        output.write(node.text);
      } else if (node is VariableNode) {
        final value = scope[node.name];
        String text;
        if (value == null) {
          if (node.filters.isNotEmpty && node.filters.first.name == 'default') {
            text = '';
          } else {
            throw TemplateError(node.pos, 'unknown variable ${node.name}');
          }
        } else if (value is List<String>) {
          throw TemplateError(node.pos, '${node.name} is a list');
        } else {
          text = value as String;
        }
        for (final filter in node.filters) {
          text = applyFilter(filter, text);
        }
        output.write(text);
      } else if (node is BlockNode) {
        if (node.kind == 'if' || node.kind == 'unless') {
          final value = scope[node.name];
          final truthy = value is String ? value.isNotEmpty : value is List<String> && value.isNotEmpty;
          final takeBody = node.kind == 'if' ? truthy : !truthy;
          visit(takeBody ? node.body : node.elseBody, scope);
        } else {
          final value = scope[node.name];
          if (value == null) throw TemplateError(node.pos, 'unknown variable ${node.name}');
          if (value is! List<String>) throw TemplateError(node.pos, '${node.name} is not a list');
          for (var index = 0; index < value.length; index++) {
            final nested = Map<String, Object>.from(scope)
              ..['item'] = value[index]
              ..['index'] = '${index + 1}'
              ..['first'] = index == 0 ? '1' : ''
              ..['last'] = index == value.length - 1 ? '1' : '';
            visit(node.body, nested);
          }
        }
      }
    }
  }

  visit(nodes, values);
  return output.toString();
}

/// Returns sorted unique variable names referenced by [nodes].
List<String> freeNames(List<Node> nodes) {
  final names = <String>{};
  void visit(List<Node> sequence, Set<String> locals) {
    for (final node in sequence) {
      if (node is VariableNode) {
        if (!locals.contains(node.name)) names.add(node.name);
      } else if (node is BlockNode) {
        if (!locals.contains(node.name)) names.add(node.name);
        if (node.kind == 'each') {
          visit(node.body, <String>{...locals, 'item', 'index', 'first', 'last'});
        } else {
          visit(node.body, locals);
          visit(node.elseBody, locals);
        }
      }
    }
  }

  visit(nodes, <String>{});
  final result = names.toList()..sort();
  return result;
}
