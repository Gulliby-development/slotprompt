import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('vars_blocks', () {
    row(['vars'], '{{#if a}}{{ b }}{{else}}{{ c }}{{/if}}', 0, 'a\nb\nc\n', '');
    row(['vars'], '{{#each xs}}{{ item }}{{ index }}{{ first }}{{ last }}{{ y }}{{/each}}', 0, 'xs\ny\n', '');
    row(['vars'], '{{ item }}{{#each xs}}{{ item }}{{/each}}{{ last }}', 0, 'item\nlast\nxs\n', '');
    row(['vars'], '{{#each item}}{{/each}}', 0, 'item\n', '');
    row(['vars'], '{{#each xs}}{{#each ys}}{{ item }}{{/each}}{{/each}}', 0, 'xs\nys\n', '');
    row(['vars'], '{{#unless a}}{{#if a}}{{/if}}{{/unless}}', 0, 'a\n', '');
    row(['vars'], '{{#each xs}}{{#if item}}{{/if}}{{else}}', 1, '', 'slotprompt: 1:32: unexpected {{else}}\n');
    row(['vars'], '{{#if a}}', 1, '', 'slotprompt: 1:1: unclosed {{#if}}\n');
    row(['vars'], '{{#each xs}}{{#if first}}a{{else}}{{ other }}{{/if}}{{/each}}', 0, 'other\nxs\n', '');
  });
}
