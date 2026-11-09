import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('block_errors', () {
    row(['render'], '{{#if a}}x', 1, '', 'slotprompt: 1:1: unclosed {{#if}}\n');
    row(['render'], 'a\n  {{#each xs}}{{#if a}}x{{/if}}', 1, '', 'slotprompt: 2:3: unclosed {{#each}}\n');
    row(['render'], '{{/if}}', 1, '', 'slotprompt: 1:1: unexpected {{/if}}\n');
    row(['render', '--var', 'a=1'], '{{#if a}}{{/each}}', 1, '', 'slotprompt: 1:10: unexpected {{/each}}\n');
    row(['render'], '{{#unless a}}{{/if}}', 1, '', 'slotprompt: 1:14: unexpected {{/if}}\n');
    row(['render'], '{{#when a}}{{/when}}', 1, '', 'slotprompt: 1:1: unknown block when\n');
    row(['render'], '{{#if}}x{{/if}}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['render'], '{{#if a b}}x{{/if}}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['render'], '{{#if 9}}x{{/if}}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['render'], '{{else}}', 1, '', 'slotprompt: 1:1: unexpected {{else}}\n');
    row(['render'], '{{#if a}}1{{else}}2{{else}}3{{/if}}', 1, '', 'slotprompt: 1:20: unexpected {{else}}\n');
    row(['render'], '{{#each xs}}{{else}}{{/each}}', 1, '', 'slotprompt: 1:13: unexpected {{else}}\n');
    row(['render'], '{{#if a}}{{ b c }}', 1, '', 'slotprompt: 1:10: bad name\n');
    row(['render'], '{{ b c }}{{#if a}}', 1, '', 'slotprompt: 1:1: bad name\n');
    row(['render', '--var', 'a=1'], '{{#if a}}x{{/if}}{{/if}}', 1, '', 'slotprompt: 1:18: unexpected {{/if}}\n');
    row(['render'], '{{#each missing}}{{/each}}{{#if a}}', 1, '', 'slotprompt: 1:27: unclosed {{#if}}\n');
  });
}
