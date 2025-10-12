import 'package:tekartik_core_node/console.dart';
import 'package:tekartik_stdio_node/process.dart';
import 'package:tekartik_stdio_node/readline.dart';

void main(List<String> arguments) async {
  // ignore: avoid_print
  print('print: Hello');
  console.out.writeln('Hello console stdout');
  console.err.writeln('Hello console stderr');
  var lr = readline;
  var answer = await lr.question('Question? ');
  console.out.writeln('Answer: $answer');
  lr.close();
  process.exit(0);
}
