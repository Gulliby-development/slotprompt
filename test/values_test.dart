import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('values', () {
    row(['render', '--var', 'a=b'], '{{ a }}', 0, 'b', '');
    row(['render', '--var', 'a='], '[{{ a }}]', 0, '[]', '');
    row(['render', '--var', 'a=x=y'], '{{ a }}', 0, 'x=y', '');
    row(['render', '--var', 'a=1', '--var', 'b=2'], '{{a}}-{{ b }}-{{a}}', 0, '1-2-1', '');
    row(['render', '--var', 'a=caf\u{E9}'], '{{ a }}', 0, 'caf\u{E9}', '');
    row(['render', '--var', 'a={{ b }}'], '{{ a }}', 0, '{{ b }}', '');
    row(['render', '--var', 'a=1'], '{{ A }}', 1, '', 'slotprompt: 1:1: unknown variable A\n');
    row(['render', '--var', '_x1=ok'], '{{ _x1 }}', 0, 'ok', '');
    row(['render'], '{{ missing }}', 1, '', 'slotprompt: 1:1: unknown variable missing\n');
    row(['render', '--var', 'a=1'], 'line one\n    {{ missing }}', 1, '', 'slotprompt: 2:5: unknown variable missing\n');
    row(['render', '--list', 'xs=a,b'], '{{ xs }}', 1, '', 'slotprompt: 1:1: xs is a list\n');
    row(['render', '--var', 'a=1'], '{{ missing }} {{', 1, '', 'slotprompt: 1:15: unclosed tag\n');
  });
}
