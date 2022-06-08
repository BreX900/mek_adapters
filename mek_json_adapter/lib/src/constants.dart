import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart' as $path;

const generatedCodeTitle = '// GENERATED CODE - DO NOT MODIFY BY HAND';

const mekAdaptableLibrary = 'package:mek_adaptable/mek_adaptable.dart';

final emitter = DartEmitter(useNullSafetySyntax: true, orderDirectives: true);

void main() {
  final path = './uno/due/tre';

  print($path.normalize($path.join(path, '../quattro')));
}
