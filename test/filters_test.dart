import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('filters', () {
    row(['render', '--var', 'a=Hello, World'], '{{ a | upper }}', 0, 'HELLO, WORLD', '');
    row(['render', '--var', 'a=Hello, WORLD'], '{{ a | lower }}', 0, 'hello, world', '');
    row(['render', '--var', 'a=caf\u{E9} \u{DF}'], '{{ a | upper }}', 0, 'CAF\u{E9} \u{DF}', '');
    row(['render', '--var', 'a=  \t x y \n'], '[{{ a | trim }}]', 0, '[x y]', '');
    row(['render', '--var', 'a=\u{A0}x'], '[{{ a | trim }}]', 0, '[\u{A0}x]', '');
    row(['render', '--var', 'a=say "hi"'], '{{ a | json }}', 0, '"say \\"hi\\""', '');
    row(['render', '--var', 'a=x\\y'], '{{ a | json }}', 0, '"x\\\\y"', '');
    row(['render', '--var', 'a=l1\nl2\ttab'], '{{ a | json }}', 0, '"l1\\nl2\\ttab"', '');
    row(['render', '--var', 'a=caf\u{E9} \u{1F600}'], '{{ a | json }}', 0, '"caf\u{E9} \u{1F600}"', '');
    row(['render', '--var', 'a='], '{{ a | json }}', 0, '""', '');
    row(['render', '--var', 'a= Ab '], '{{a|upper}}{{ a |lower}}{{ a | trim }}', 0, ' AB  ab Ab', '');
    row(['render', '--list', 'a=x'], '{{ a | upper }}', 1, '', 'slotprompt: 1:1: a is a list\n');
  });
}
