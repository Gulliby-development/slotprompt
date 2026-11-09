<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# slotprompt

[![CI](https://github.com/Gulliby-development/slotprompt/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/slotprompt/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

slotprompt is a strict Dart prompt-template renderer for applications that assemble prompts for language-model calls, agents, and evaluations. Unlike ordinary string interpolation, it checks the entire template before rendering, reports positioned errors instead of silently substituting missing values, and can list the inputs a template needs. It is intended for developers using prompts in scripts, applications, or CI.

## Install and run

Install the Dart SDK (the project requires Dart `^3.8.0`) and fetch the scaffold dependencies:

```text
dart pub get
```

Run the interpreter from the project root:

```text
dart run bin/slotprompt.dart render --var name=World
```

Or compile a native executable:

```text
dart compile exe bin/slotprompt.dart -o slotprompt
```

On Windows, choose an output name such as `slotprompt.exe` and invoke it as `slotprompt.exe`; on macOS and Linux, the example output name is `slotprompt`. Commands above are shown without shell-specific stdin redirection. For file input, shells differ: POSIX shells use `< template.txt`, while PowerShell can use `Get-Content -Raw template.txt | ...`; PowerShell's text pipeline may normalize line endings or encoding, so use byte-preserving redirection/tools when those distinctions matter. Quote arguments according to the shell in use (PowerShell and POSIX shells have different quoting and escaping rules). These commands work from Windows, macOS, and Linux with the respective Dart SDK and shell conventions.

## Command line

```text
usage: slotprompt render [--var NAME=VALUE]... [--list NAME=A,B,...]...
       slotprompt vars
```

`render` reads the template from standard input, renders it to standard output, and adds no final line feed. `vars` reads the same input and prints sorted, unique free names, one per line; a template with no free names prints nothing. Each vars name line ends in LF. The commands return status 0 on success, 1 for invalid UTF-8 or a template error, and 2 for command/option errors. Diagnostics go to standard error as one LF-terminated line, and a failed render produces no partial standard output.

The first word selects the command. `help`, `-h`, and `--help` print the two-line synopsis and ignore later words; `--version` prints `slotprompt 0.1.0` and also ignores later words. No words prints usage to standard error with status 2. Any other first word is an unknown command. `vars` accepts no further words.

For `render`, options are read and validated from left to right before standard input is read. Use `--var NAME=VALUE` for text and `--list NAME=A,B,...` for a list. A name is ASCII: a letter or underscore, followed by letters, digits, or underscores. The first `=` divides name from value, so later equals signs belong to the value; an empty value is permitted. A name cannot be supplied twice, even once as `--var` and once as `--list`.

In a list argument, commas separate items, `\\,` represents a comma within an item, and `\\\\` represents a backslash. A backslash before any other character remains unchanged. The empty list argument is an empty list; `a,,b,` contains `a`, an empty item, `b`, and an empty item. This syntax is part of the argument value, so quote it using the rules of your shell.

### Library API

`package:slotprompt/slotprompt.dart` exports `Result`, `run(List<String> args, String input)`, and `readsStdin(List<String> args)`. `Result` exposes `status`, `out`, and `err`. `run` is an in-memory, string-based interface: it validates command arguments and processes the supplied template string, but does not perform byte decoding or process I/O. `readsStdin` is true only for a valid `render` or `vars` invocation; the executable uses it to avoid reading stdin for help and invalid commands. At the process boundary the executable reads UTF-8 bytes, drops one leading UTF-8 BOM (EF BB BF), and reports `slotprompt: input is not valid UTF-8` with status 1, empty stdout, and no template parsing for malformed UTF-8. The decoder check happens before the template is treated as text.

## Template language

Text outside tags is copied unchanged. `{{` starts a tag, which ends at the first following `}}`; `}}` outside a tag is ordinary text. The two-character sequence `\\{{` emits literal `{{` with the backslash removed, wherever it occurs (including after another backslash). Within a tag, space, tab, CR, and LF are whitespace, and that whitespace is trimmed around the tag body. Comments `{{! anything }}` emit nothing and end at the first `}}`; a comment may span lines and any `{{` inside it is ordinary comment text. A variable's value is not parsed again, so braces in a value remain literal output.

### Variables and tags

A plain variable tag such as `{{ name }}` writes its text value. A missing variable is an error unless its first filter is `default`. Lists cannot be printed as text. For example, the request's literal case `run 'render' '--var' 'a=b' stdin='{{ a }}' => 0 'b' ''` demonstrates a plain variable; `run 'render' stdin='{{! note }}x{{!}}y' => 0 'xy' ''` demonstrates comments; and `run 'render' stdin='a \\{{ b }} c' => 0 'a {{ b }} c' ''` demonstrates escaped opening braces.

`{{#if NAME}}...{{else}}...{{/if}}` selects its first body for a nonempty text or list, otherwise its else body (or empty output if no else exists). A missing condition is false; whitespace and `0` are nonempty text. `unless` reverses that condition. For example, the literal request cases `run 'render' '--var' 'a=0' stdin='{{#if a}}yes{{else}}no{{/if}}' => 0 'yes' ''` and `run 'render' stdin='{{#unless nope}}x{{/unless}}' => 0 'x' ''` show truthiness and the missing-name rule.

`{{#each NAME}}...{{/each}}` requires a list and renders its body once per item in order; an empty list emits nothing. Inside the body, `item` is the current item, `index` is the one-based index, and `first`/`last` are `1` for the corresponding item and empty text otherwise. These four names shadow supplied values, belong to the innermost nested loop, and are restored when that loop ends. Outside an each body they are ordinary variable names. `else` is not allowed in an each block. The literal request example `run 'render' '--list' 'xs=a,b,c' stdin='{{#each xs}}{{ index }}.{{ item }} {{/each}}' => 0 '1.a 2.b 3.c ' ''` demonstrates iteration.

Blocks may nest. Conditions evaluate only the selected branch, so errors in an unselected branch do not occur; `vars`, by contrast, discovers names in both branches. The each source name is resolved in the surrounding scope, while loop-local names are excluded from free names only within that loop body (including nested bodies). Free names are sorted by code point and deduplicated.

The complete template is parsed before evaluation. The first syntax error in source order wins regardless of values. After successful parsing, rendering reports the first evaluation error in output order; an untaken branch is not evaluated.

## Filters

A variable may have a left-to-right pipeline, for example `{{ name | trim | upper }}`. A pipe separates filters except inside a double-quoted string; within quotes, backslash escapes the next character for segmentation. Filter names and arguments are separated by tag whitespace.

| Filter | Behavior and example |
| --- | --- |
| `upper` | Converts ASCII letters only: `{{ a | upper }}` with `a=Hello, World` produces `HELLO, WORLD`. |
| `lower` | Converts ASCII letters only: `{{ a | lower }}` with `a=Hello, WORLD` produces `hello, world`. |
| `trim` | Removes only space, tab, CR, and LF at both ends: `{{ a | trim }}` with `a=  x y ` produces `x y`. |
| `json` | Produces a JSON string literal including quotes. `"` and `\\` are escaped; LF, CR, tab, backspace, and form feed become `\\n`, `\\r`, `\\t`, `\\b`, and `\\f`; other characters below U+0020 use lowercase `\\u00xx`. Other characters, including non-ASCII and U+007F, remain as written. Example: `{{ a | json }}` for `a=say "hi"` produces `"say \\"hi\\""`. |
| `default "TEXT"` | Uses TEXT only when the value is empty. TEXT must be double-quoted; only `\\"` and `\\\\` escapes are allowed. A missing variable is treated as empty only when `default` is the first filter. Example: `{{ a | default "none" }}` with an unset `a` produces `none`. |
| `truncate N` | If the value has more than N Unicode code points, emits its first N code points plus `...`; otherwise leaves it unchanged. N is 1–4 decimal digits and at least 1 (leading zeroes are allowed). Example: `{{ a | truncate 5 }}` with `a=abcdef` produces `abcde...`. |
| `indent N` | Adds N spaces after every LF, including a trailing LF; N is 1–4 decimal digits and at least 1. Example: `{{ a | indent 2 }}` with `a=one` followed by LF and `two` produces `one` followed by LF and two spaces, then `two`. |

Filter arguments are validated while parsing, before any variable is evaluated. Thus an unknown filter later in a template is reported even if an earlier variable would be missing. JSON escaping and truncation operate on Unicode code points and do not split surrogate pairs.

## Encoding, positions, and diagnostics

The executable accepts valid UTF-8, removes one leading UTF-8 BOM, and rejects malformed UTF-8 before parsing. Lines are separated by LF only; CR is an ordinary character for line/column accounting. Error positions identify the opening `{{`, use one-based lines and columns, and count Unicode code points (so a character outside the Basic Multilingual Plane counts as one column).

Command errors (status 2) are checked before stdin is read. Exact messages are:

- No command: usage text on stderr. Unknown command: `slotprompt: unknown command WORD`.
- Extra words to vars: `slotprompt: vars takes no arguments`.
- Invalid render word: `slotprompt: unexpected argument WORD`.
- A final `--var` or `--list`: `slotprompt: --var needs NAME=VALUE` or `slotprompt: --list needs NAME=VALUE`.
- Missing `=` or invalid name: `slotprompt: bad --var argument: TEXT` or `slotprompt: bad --list argument: TEXT`.
- Repeated name: `slotprompt: NAME given twice`.

Template errors (status 1) have the envelope `slotprompt: LINE:COL: MESSAGE`. Parsing errors are reported in source order, before evaluation:

- A `{{` without a later `}}`: `unclosed tag`; an empty body after trimming: `empty tag`.
- A `{{#KIND NAME}}` with unknown KIND: `unknown block KIND`; malformed NAME: `bad name`. A closing tag with unknown KIND: `unknown block KIND`; a closing kind that does not match the innermost open block (or has no opener): `unexpected {{/KIND}}`.
- `{{else}}` outside an if/unless or repeated in one: `unexpected {{else}}`; it is also an error in each.
- A variable tag whose first part is not one valid name: `bad name`.
- An empty filter segment: `empty filter`; an unrecognized filter: `unknown filter NAME`; an argument to `upper`, `lower`, `trim`, or `json`: `filter NAME takes no argument`; invalid `default`, `truncate`, or `indent` argument: `bad argument for NAME`.
- At end of input, an open block: `unclosed {{#KIND}}`, positioned at its opening tag; if several remain open, the innermost is reported.

After parsing, evaluation errors occur in output order at the relevant tag: `unknown variable NAME` for an unset variable without `default` first or an unset each source; `NAME is a list` when a list is used as text; `NAME is not a list` when each receives text. Conditions treat missing values as false. Syntax always precedes evaluation, and no partial output is returned on error.

## Development

From the project root, format Dart files, analyze with fatal infos, and run tests:

```text
dart format .
dart analyze --fatal-infos
dart test
```

The repository's formatting check uses `dart format --output=none --set-exit-if-changed .`. The project uses only the Dart SDK plus the scaffold's `lints` and `test` development dependencies; no runtime package is required.

## License

This project is available under the [MIT License](LICENSE).

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R82).
