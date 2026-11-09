import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('cli', () {
    row([], '', 2, '', 'usage: slotprompt render [--var NAME=VALUE]... [--list NAME=A,B,...]...\n       slotprompt vars\n');
    row(['help'], '', 0, 'usage: slotprompt render [--var NAME=VALUE]... [--list NAME=A,B,...]...\n       slotprompt vars\n', '');
    row(['-h', 'x'], '', 0, 'usage: slotprompt render [--var NAME=VALUE]... [--list NAME=A,B,...]...\n       slotprompt vars\n', '');
    row(['--help', 'render'], '', 0, 'usage: slotprompt render [--var NAME=VALUE]... [--list NAME=A,B,...]...\n       slotprompt vars\n', '');
    row(['--version'], '', 0, 'slotprompt 0.1.0\n', '');
    row(['--version', 'x'], '', 0, 'slotprompt 0.1.0\n', '');
    row(['frob'], '', 2, '', 'slotprompt: unknown command frob\n');
    row(['Render'], '', 2, '', 'slotprompt: unknown command Render\n');
    row([''], '', 2, '', 'slotprompt: unknown command \n');
    row(['vars', 'x'], '', 2, '', 'slotprompt: vars takes no arguments\n');
    row(['render', 'x'], '', 2, '', 'slotprompt: unexpected argument x\n');
    row(['render', '--vars'], '', 2, '', 'slotprompt: unexpected argument --vars\n');
  });
}
