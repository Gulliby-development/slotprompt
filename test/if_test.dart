import 'harness.dart';
import 'package:test/test.dart';

void main() {
  test('if', () {
    row(['render', '--var', 'a=1'], '{{#if a}}yes{{/if}}', 0, 'yes', '');
    row(['render', '--var', 'a='], '{{#if a}}yes{{/if}}', 0, '', '');
    row(['render', '--var', 'a='], '{{#if a}}yes{{else}}no{{/if}}', 0, 'no', '');
    row(['render', '--var', 'a=0'], '{{#if a}}yes{{else}}no{{/if}}', 0, 'yes', '');
    row(['render'], '{{#if nope}}yes{{else}}no{{/if}}', 0, 'no', '');
    row(['render', '--var', 'a= '], '{{#if a}}yes{{/if}}', 0, 'yes', '');
    row(['render', '--list', 'xs=a'], '{{#if xs}}yes{{else}}no{{/if}}', 0, 'yes', '');
    row(['render', '--list', 'xs='], '{{#if xs}}yes{{else}}no{{/if}}', 0, 'no', '');
    row(['render', '--var', 'a='], '{{#unless a}}no a{{/unless}}', 0, 'no a', '');
    row(['render', '--var', 'a=1'], '{{#unless a}}no a{{else}}has a{{/unless}}', 0, 'has a', '');
    row(['render'], '{{#unless nope}}x{{/unless}}', 0, 'x', '');
    row(['render', '--var', 'a=v'], '[{{#if a}}\n{{ a }}\n{{/if}}]', 0, '[\nv\n]', '');
    row(['render'], '{{#if a}}{{ missing }}{{/if}}', 0, '', '');
    row(['render', '--var', 'a=1'], '{{#if  a }}t{{/ if }}', 0, 't', '');
  });
}
