import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('filter_args', () {
    row(['render', '--var', 'a=set'], '{{ a | default "none" }}', 0, 'set', '');
    row(['render', '--var', 'a='], '{{ a | default "none" }}', 0, 'none', '');
    row(['render'], '{{ a | default "none" }}', 0, 'none', '');
    row(['render'], '{{ a | default "" }}[]', 0, '[]', '');
    row(['render'], '{{ a | default "q\\"b\\\\s" }}', 0, 'q"b\\s', '');
    row(['render'], '{{ a | default "x | y" }}', 0, 'x | y', '');
    row(['render', '--var', 'a=abcdef'], '{{ a | truncate 5 }}', 0, 'abcde...', '');
    row(['render', '--var', 'a=abcde'], '{{ a | truncate 5 }}', 0, 'abcde', '');
    row(['render', '--var', 'a=\u{E9}\u{E9}\u{E9}\u{E9}'], '{{ a | truncate 3 }}', 0, '\u{E9}\u{E9}\u{E9}...', '');
    row(['render', '--var', 'a=\u{1F600}\u{1F600}\u{1F600}'], '{{ a | truncate 2 }}', 0, '\u{1F600}\u{1F600}...', '');
    row(['render', '--var', 'a=abcdefghijklmnop'], '{{ a | truncate 0012 }}', 0, 'abcdefghijkl...', '');
    row(['render', '--var', 'a=one\ntwo\n'], '{{ a | indent 2 }}', 0, 'one\n  two\n  ', '');
    row(['render', '--var', 'a=x'], '{{ a | indent 9999 }}|', 0, 'x|', '');
    row(['render', '--var', 'a=\n\n'], '{{ a | indent 1 }}', 0, '\n \n ', '');
  });
}
