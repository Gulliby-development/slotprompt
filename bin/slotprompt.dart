import 'dart:convert';
import 'dart:io';

import 'package:slotprompt/slotprompt.dart';

Future<void> main(List<String> args) async {
  var input = '';
  if (readsStdin(args)) {
    final bytes = <int>[];
    await for (final chunk in stdin) {
      bytes.addAll(chunk);
    }
    try {
      input = const Utf8Decoder().convert(bytes);
    } on FormatException {
      stderr.add(utf8.encode('slotprompt: input is not valid UTF-8\n'));
      await stderr.flush();
      exit(1);
    }
  }
  final result = run(args, input);
  stdout.add(utf8.encode(result.out));
  stderr.add(utf8.encode(result.err));
  await stdout.flush();
  await stderr.flush();
  exit(result.status);
}
