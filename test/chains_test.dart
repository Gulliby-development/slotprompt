import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('chains', () {
    row(['render', '--var', 'a= abc '], '{{ a | trim | upper }}', 0, 'ABC', '');
    row(['render', '--var', 'a=abcdef'], '{{ a | upper | truncate 3 }}', 0, 'ABC...', '');
    row(['render', '--var', 'a=abcdef'], '{{ a | truncate 3 | upper }}', 0, 'ABC...', '');
    row(['render'], '{{ a | default "x" | upper }}', 0, 'X', '');
    row(['render'], '{{ a | upper | default "x" }}', 1, '', 'slotprompt: 1:1: unknown variable a\n');
    row(['render', '--var', 'a="q"x'], '{{ a | truncate 2 | json | upper }}', 0, '"\\"Q..."', '');
    row(['render', '--var', 'a=AB'], '{{ a | lower }}{{ b | default "-" | upper }}', 0, 'ab-', '');
    row(['vars'], '{{ a | upper }}{{ b | trim }}{{ a | json }}', 0, 'a\nb\n', '');
    row(['render', '--var', 'a=l1\nl2'], '{{ a | indent 2 | json }}', 0, '"l1\\n  l2"', '');
  });
}
