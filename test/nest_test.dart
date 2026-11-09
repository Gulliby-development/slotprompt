import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('nest', () {
    row(['render', '--list', 'xs=a,b', '--list', 'ys=1,2'], '{{#each xs}}{{#each ys}}{{ item }}{{/each}};{{/each}}', 0, '12;12;', '');
    row(['render', '--list', 'xs=a,b', '--list', 'ys=1'], '{{#each xs}}{{ item }}{{#each ys}}{{ item }}{{/each}}{{ item }} {{/each}}', 0, 'a1a b1b ', '');
    row(['render', '--list', 'xs=a,b,c'], '{{#each xs}}{{ item }}{{#unless last}}, {{/unless}}{{/each}}', 0, 'a, b, c', '');
    row(['render', '--list', 'xs=a,b,c'], '{{#each xs}}{{#if first}}[{{else}}|{{/if}}{{ item }}{{/each}}]', 0, '[a|b|c]', '');
    row(['render', '--var', 'a=1', '--list', 'xs=p,q'], '{{#if a}}{{#each xs}}{{ item }}{{/each}}{{else}}none{{/if}}', 0, 'pq', '');
    row(['render', '--list', 'xs=p,q'], '{{#if a}}{{#each xs}}{{ item }}{{/each}}{{else}}none{{/if}}', 0, 'none', '');
    row(['render', '--var', 'b=1'], '{{#if a}}{{#if b}}ab{{else}}a{{/if}}{{else}}{{#if b}}b{{else}}-{{/if}}{{/if}}', 0, 'b', '');
    row(['render', '--list', 'xs=a'], '{{#each xs}}{{#each item}}x{{/each}}{{/each}}', 1, '', 'slotprompt: 1:13: item is not a list\n');
    row(['render', '--list', 'xs=a,b'], '{{#each xs}}{{#each xs}}{{ index }}{{/each}}{{/each}}', 0, '1212', '');
    row(['render', '--list', 'xs=a', '--list', 'ys=p,q'], '{{#each xs}}{{ index }}{{#each ys}}{{ index }}{{/each}}{{ index }}{{/each}}', 0, '1121', '');
  });
}
