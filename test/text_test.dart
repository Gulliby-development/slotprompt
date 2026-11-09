import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('text', () {
    row(['render'], '', 0, '', '');
    row(['render'], 'plain text\n', 0, 'plain text\n', '');
    row(['render'], 'no tags } here }} and {x}', 0, 'no tags } here }} and {x}', '');
    row(['render'], 'a \\{{ b }} c', 0, 'a {{ b }} c', '');
    row(['render', '--var', 'a=1'], '\\\\{{ a }}', 0, '\\{{ a }}', '');
    row(['render'], '{{! note }}x{{!}}y', 0, 'xy', '');
    row(['render'], 'a{{! multi\nline }}b', 0, 'ab', '');
    row(['render'], '{{ a }', 1, '', 'slotprompt: 1:1: unclosed tag\n');
    row(['render'], 'one\ntwo {{', 1, '', 'slotprompt: 2:5: unclosed tag\n');
    row(['render'], '{{}}', 1, '', 'slotprompt: 1:1: empty tag\n');
    row(['render'], '{{   }}', 1, '', 'slotprompt: 1:1: empty tag\n');
    row(['render'], '{{ 1x }}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['render', '--var', 'a=1'], '{{ a b }}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['render'], 'a\r\nb\r\n  {{ x', 1, '', 'slotprompt: 3:3: unclosed tag\n');
    row(['render'], '\u{E9}\u{E9} {{ x', 1, '', 'slotprompt: 1:4: unclosed tag\n');
    row(['render'], '\u{1F600}{{ x', 1, '', 'slotprompt: 1:2: unclosed tag\n');
    row(['render', '--var', 'a=1'], '{{ a\n}}', 0, '1', '');
  });
}
