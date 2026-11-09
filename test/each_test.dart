import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('each', () {
    row(['render', '--list', 'xs=a,b,c'], '{{#each xs}}<{{ item }}>{{/each}}', 0, '<a><b><c>', '');
    row(['render', '--list', 'xs=a,b,c'], '{{#each xs}}{{ index }}.{{ item }} {{/each}}', 0, '1.a 2.b 3.c ', '');
    row(['render', '--list', 'xs=a,b,c'], '{{#each xs}}{{#if first}}F{{/if}}{{#if last}}L{{/if}}{{ index }} {{/each}}', 0, 'F1 2 L3 ', '');
    row(['render', '--list', 'xs='], '[{{#each xs}}x{{/each}}]', 0, '[]', '');
    row(['render', '--list', 'xs=a\\,b,c'], '{{#each xs}}<{{ item }}>{{/each}}', 0, '<a,b><c>', '');
    row(['render', '--list', 'xs=a\\\\,b\\n'], '{{#each xs}}<{{ item }}>{{/each}}', 0, '<a\\><b\\n>', '');
    row(['render', '--list', 'xs=a,,b,'], '{{#each xs}}<{{ item }}>{{/each}}', 0, '<a><><b><>', '');
    row(['render', '--list', 'xs=only'], '{{#each xs}}<{{ item }}>{{/each}}', 0, '<only>', '');
    row(['render', '--var', 'xs=a,b'], '{{#each xs}}<{{ item }}>{{/each}}', 1, '', 'slotprompt: 1:1: xs is not a list\n');
    row(['render'], '{{#each nope}}x{{/each}}', 1, '', 'slotprompt: 1:1: unknown variable nope\n');
    row(['render', '--var', 'item=S', '--list', 'xs=a'], '{{#each xs}}{{ item }}{{/each}}', 0, 'a', '');
    row(['render', '--list', 'xs=a'], '{{#each xs}}{{/each}}{{ item }}', 1, '', 'slotprompt: 1:22: unknown variable item\n');
    row(['render', '--list', 'xs=a'], '{{#each xs}}{{ xs }}{{/each}}', 1, '', 'slotprompt: 1:13: xs is a list\n');
    row(['render', '--list', 'xs=a,b', '--var', 'y=!'], '{{#each xs}}{{ item }}{{ y }}{{/each}}', 0, 'a!b!', '');
  });
}
