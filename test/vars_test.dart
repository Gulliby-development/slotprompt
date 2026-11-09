import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('vars', () {
    row(['vars'], '', 0, '', '');
    row(['vars'], 'no tags', 0, '', '');
    row(['vars'], '{{ b }} {{ a }} {{ b }}', 0, 'a\nb\n', '');
    row(['vars'], '{{! c }}{{ a }}', 0, 'a\n', '');
    row(['vars'], '\\{{ a }}{{ b }}', 0, 'b\n', '');
    row(['vars'], '{{ A }}{{ a }}{{ _z }}', 0, 'A\n_z\na\n', '');
    row(['vars'], '{{ 1 }}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['vars'], 'x\n{{ a', 1, '', 'slotprompt: 2:1: unclosed tag\n');
    row(['vars'], '{{ a }}{{', 1, '', 'slotprompt: 1:8: unclosed tag\n');
  });
}
