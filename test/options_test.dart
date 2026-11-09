import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('options', () {
    row(['render', '--var'], '', 2, '', 'slotprompt: --var needs NAME=VALUE\n');
    row(['render', '--list'], '', 2, '', 'slotprompt: --list needs NAME=VALUE\n');
    row(['render', '--var', 'a'], '', 2, '', 'slotprompt: bad --var argument: a\n');
    row(['render', '--var', '1a=x'], '', 2, '', 'slotprompt: bad --var argument: 1a=x\n');
    row(['render', '--list', '=x'], '', 2, '', 'slotprompt: bad --list argument: =x\n');
    row(['render', '--var', 'a=1', '--list', 'a=x'], '', 2, '', 'slotprompt: a given twice\n');
    row(['render', '--var', 'a=1', '--var', 'a=2'], '', 2, '', 'slotprompt: a given twice\n');
    row(['render', '--var', 'a=1', 'stray'], '', 2, '', 'slotprompt: unexpected argument stray\n');
    reads(['render'], true);
    reads(['vars'], true);
    reads(['render', '--var', 'a=1', '--list', 'b=x,y'], true);
    reads(['render', '--var', 'a'], false);
    reads(['vars', 'x'], false);
    reads(['help'], false);
    reads([], false);
  });
}
