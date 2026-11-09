import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('filter_errors', () {
    row(['render'], '{{ a | shout }}', 1, '', 'slotprompt: 1:1: unknown filter shout\n');
    row(['render'], '{{ a | }}', 1, '', 'slotprompt: 1:1: empty filter\n');
    row(['render'], '{{ a | upper | }}', 1, '', 'slotprompt: 1:1: empty filter\n');
    row(['render'], '{{ a | upper now }}', 1, '', 'slotprompt: 1:1: filter upper takes no argument\n');
    row(['render'], '{{ a | json 1 }}', 1, '', 'slotprompt: 1:1: filter json takes no argument\n');
    row(['render'], 'x\n{{ a | trim x }}', 1, '', 'slotprompt: 2:1: filter trim takes no argument\n');
    row(['render'], '{{ a | default }}', 1, '', 'slotprompt: 1:1: bad argument for default\n');
    row(['render'], '{{ a | default none }}', 1, '', 'slotprompt: 1:1: bad argument for default\n');
    row(['render'], '{{ a | default "x }}', 1, '', 'slotprompt: 1:1: bad argument for default\n');
    row(['render'], '{{ a | default "x" "y" }}', 1, '', 'slotprompt: 1:1: bad argument for default\n');
    row(['render'], '{{ a | default \'x\' }}', 1, '', 'slotprompt: 1:1: bad argument for default\n');
    row(['render'], '{{ a | truncate }}', 1, '', 'slotprompt: 1:1: bad argument for truncate\n');
    row(['render'], '{{ a | truncate 0 }}', 1, '', 'slotprompt: 1:1: bad argument for truncate\n');
    row(['render'], '{{ a | truncate 10000 }}', 1, '', 'slotprompt: 1:1: bad argument for truncate\n');
    row(['render'], '{{ a | indent -1 }}', 1, '', 'slotprompt: 1:1: bad argument for indent\n');
    row(['render'], '{{ a | indent two }}', 1, '', 'slotprompt: 1:1: bad argument for indent\n');
    row(['render'], '{{ missing }}{{ a | nope }}', 1, '', 'slotprompt: 1:14: unknown filter nope\n');
  });
}
