import 'package:dart_style/dart_style.dart';
import 'package:mek_json_adapter/src/constants.dart';

class DartDecorator {
  final DartFormatter formatter;
  final List<String> imports;

  DartDecorator({
    this.imports = const [],
  }) : formatter = DartFormatter();

  String decorate({
    Iterable<String> imports = const [],
    required Object code,
  }) {
    final contentBuffer = StringBuffer();

    contentBuffer
      ..writeln(generatedCodeTitle)
      ..writeln();

    for (final import in {...this.imports, ...imports}) {
      contentBuffer.writeln('import \'$import\';');
    }

    contentBuffer.write(code);

    return formatter.format(contentBuffer.toString());
  }
}

//   static final headerLine = '// '.padRight(77, '*');
// ..writeln(headerLine)
// // ..writeAll(
// //   LineSplitter.split(item.generatorDescription).map((line) => '// $line\n'),
// // )
// ..writeln(headerLine)
