import 'package:slotprompt/slotprompt.dart';
import 'package:test/test.dart';

/// row ARGS STDIN STATUS OUT ERR: runs the command line with STDIN as standard input and compares the exit status,
/// the standard output and the standard error.
void row(List<String> args, String stdin, int status, String out, String err) {
  final result = run(args, stdin);
  expect(result.status, status);
  expect(result.out, out);
  expect(result.err, err);
}

/// reads ARGS EXPECTED: whether the entry point reads standard input for this command line.
void reads(List<String> args, bool expected) {
  expect(readsStdin(args), expected);
}
